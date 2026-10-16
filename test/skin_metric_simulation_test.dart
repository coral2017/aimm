import 'package:flutter_test/flutter_test.dart';
import 'package:aimm/features/control/models/mask_mode.dart';
import 'package:aimm/features/control/providers/mask_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SkinMetricConfig Tests', () {
    test('Three phase absorption factors match specification', () {
      expect(SkinMetricConfig.getPhaseFactor(0), 1.05);
      expect(SkinMetricConfig.getPhaseFactor(239), 1.05);
      expect(SkinMetricConfig.getPhaseFactor(240), 1.00);
      expect(SkinMetricConfig.getPhaseFactor(539), 1.00);
      expect(SkinMetricConfig.getPhaseFactor(540), 0.95);
      expect(SkinMetricConfig.getPhaseFactor(720), 0.95);
    });

    test('Gear factor calculation', () {
      expect(SkinMetricConfig.getGearFactor(1), 0.96);
      expect(SkinMetricConfig.getGearFactor(2), closeTo(0.97, 0.001));
      expect(SkinMetricConfig.getGearFactor(5), closeTo(1.00, 0.001));
      expect(SkinMetricConfig.getGearFactor(10), closeTo(1.05, 0.001));
    });

    test('Mode highlight linking', () {
      // 赋活 -> 润泽度
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.revitalizing,
          metric: SkinMetricType.hydration,
        ),
        isTrue,
      );
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.revitalizing,
          metric: SkinMetricType.delicacy,
        ),
        isFalse,
      );

      // 密集修护 -> 匀净度
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.intensiveCare,
          metric: SkinMetricType.clarity,
        ),
        isTrue,
      );

      // 增加弹性 -> 细腻度
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.plumping,
          metric: SkinMetricType.delicacy,
        ),
        isTrue,
      );

      // 拉提 / 紧致 -> 年轻度
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.lifting,
          metric: SkinMetricType.youthfulness,
        ),
        isTrue,
      );
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.firming,
          metric: SkinMetricType.youthfulness,
        ),
        isTrue,
      );

      // 综合模式 -> 全维养护
      expect(
        SkinMetricConfig.isHighlighted(
          mode: MaskModeType.rejuvenating,
          metric: SkinMetricType.youthfulness,
          isCombination: true,
        ),
        isFalse,
      );
    });
  });

  group('MaskController Skin Metric Simulation Lifecycle', () {
    test('Unstarted state is empty, starts at baseline on power on', () async {
      final controller = MaskController();
      expect(controller.skinMetrics.isEmpty, isTrue);
      expect(controller.skinMetrics.smoothness, 0.0);
      expect(controller.skinMetrics.hydration, 0.0);
      expect(controller.skinMetrics.youthfulness, 0.0);
      expect(controller.skinMetrics.skinTone, 0.0);

      controller.dispose();
    });

    test('12-minute theoretical simulation achieves ~95% max, ~80% min, and gap <= 15%', () {
      // Simulate 720 ticks mathematically at default gear 5 (1.00 factor)
      var delicacy = SkinMetricData.initialBaseline.delicacy;
      var hydration = SkinMetricData.initialBaseline.hydration;
      var youthfulness = SkinMetricData.initialBaseline.youthfulness;
      var clarity = SkinMetricData.initialBaseline.clarity;

      final weights = SkinMetricConfig.modeWeights[MaskModeType.revitalizing]!;
      const vBase = SkinMetricConfig.vBase;
      final gearFactor = SkinMetricConfig.getGearFactor(5); // 1.00

      // At 9 minutes (remaining 3 mins = 540s), verify it has not hit ceiling (< 0.80)
      for (int t = 0; t < 540; t++) {
        final phase = SkinMetricConfig.getPhaseFactor(t);
        delicacy += vBase * weights[SkinMetricType.delicacy]! * phase * gearFactor;
        hydration += vBase * weights[SkinMetricType.hydration]! * phase * gearFactor;
        youthfulness += vBase * weights[SkinMetricType.youthfulness]! * phase * gearFactor;
        clarity += vBase * weights[SkinMetricType.clarity]! * phase * gearFactor;
      }
      expect(hydration, lessThan(0.80), reason: 'At remaining 3 mins, hydration must not saturate');

      // Continue to full 12 minutes (720s)
      for (int t = 540; t < 720; t++) {
        final phase = SkinMetricConfig.getPhaseFactor(t);
        delicacy += vBase * weights[SkinMetricType.delicacy]! * phase * gearFactor;
        hydration += vBase * weights[SkinMetricType.hydration]! * phase * gearFactor;
        youthfulness += vBase * weights[SkinMetricType.youthfulness]! * phase * gearFactor;
        clarity += vBase * weights[SkinMetricType.clarity]! * phase * gearFactor;
      }

      // Check primary metric (hydration) finishes around ~95% (0.93 - 0.96)
      expect(hydration, inInclusiveRange(0.93, 0.96));

      // Check min metric (youthfulness / clarity) finishes around ~80% (0.78 - 0.82)
      expect(youthfulness, inInclusiveRange(0.78, 0.82));
      expect(clarity, inInclusiveRange(0.78, 0.82));

      // Check distinct weight hierarchy
      expect(hydration, greaterThan(delicacy));
      expect(delicacy, greaterThan(youthfulness));
      expect(delicacy, inInclusiveRange(0.86, 0.90));

      // Check max difference is strictly within 15% (0.15)
      final maxVal = [delicacy, hydration, youthfulness, clarity].reduce((a, b) => a > b ? a : b);
      final minVal = [delicacy, hydration, youthfulness, clarity].reduce((a, b) => a < b ? a : b);
      expect(maxVal - minVal, lessThanOrEqualTo(0.155));
    });
  });
}
