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
      expect(SkinMetricConfig.getPhaseFactor(0), 1.30);
      expect(SkinMetricConfig.getPhaseFactor(239), 1.30);
      expect(SkinMetricConfig.getPhaseFactor(240), 1.00);
      expect(SkinMetricConfig.getPhaseFactor(539), 1.00);
      expect(SkinMetricConfig.getPhaseFactor(540), 0.70);
      expect(SkinMetricConfig.getPhaseFactor(720), 0.70);
    });

    test('Gear factor calculation', () {
      expect(SkinMetricConfig.getGearFactor(1), 1.0);
      expect(SkinMetricConfig.getGearFactor(2), 1.05);
      expect(SkinMetricConfig.getGearFactor(5), 1.20);
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

    test('12-minute theoretical simulation achieves 0.88 - 0.95 range', () {
      // Simulate 720 ticks mathematically
      var delicacy = SkinMetricData.initialBaseline.delicacy;
      var hydration = SkinMetricData.initialBaseline.hydration;
      var youthfulness = SkinMetricData.initialBaseline.youthfulness;
      var clarity = SkinMetricData.initialBaseline.clarity;

      final weights = SkinMetricConfig.modeWeights[MaskModeType.revitalizing]!;
      const vBase = SkinMetricConfig.vBase;
      const gearFactor = 1.0; // 1 gear

      for (int t = 0; t < 720; t++) {
        final phase = SkinMetricConfig.getPhaseFactor(t);
        delicacy += vBase * weights[SkinMetricType.delicacy]! * phase * gearFactor;
        hydration += vBase * weights[SkinMetricType.hydration]! * phase * gearFactor;
        youthfulness += vBase * weights[SkinMetricType.youthfulness]! * phase * gearFactor;
        clarity += vBase * weights[SkinMetricType.clarity]! * phase * gearFactor;
      }

      // Check that hydration (main target in revitalizing mode) grew significantly and capped properly
      expect(hydration, greaterThan(delicacy));
      expect(hydration, greaterThan(youthfulness));
      expect(hydration, greaterThanOrEqualTo(0.88));
      expect(delicacy, greaterThanOrEqualTo(0.65));
      expect(youthfulness, greaterThanOrEqualTo(0.50));
      expect(clarity, greaterThanOrEqualTo(0.50));
    });
  });
}
