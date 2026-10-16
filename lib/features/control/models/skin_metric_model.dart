import 'mask_mode.dart';

enum SkinMetricType {
  delicacy, // 细腻度
  hydration, // 润泽度
  youthfulness, // 年轻度
  clarity, // 匀净度
}

class SkinMetricConfig {
  static const double baseTotalGrowth = 0.70; // 累计满程基础增量期望 (基线0.10 + 0.70 ≈ 0.80 最低指标)
  static const int totalSeconds = 720; // 12 分钟 (720秒)
  // vBase * primaryWeight(1.214) * 720 ≈ 0.85 -> 满程达约 0.95；最低指标(1.00)达 0.80，间距控制在 15% 内
  static const double vBase = baseTotalGrowth / totalSeconds;

  // 模式权重映射表 (主攻指标 1.214 -> ~95%，次要指标 1.114 -> ~88%，其他基础 1.00 -> ~80%)
  static const Map<MaskModeType, Map<SkinMetricType, double>> modeWeights = {
    MaskModeType.revitalizing: {
      SkinMetricType.delicacy: 1.114,
      SkinMetricType.hydration: 1.214, // 主增 ~95%
      SkinMetricType.youthfulness: 1.00,
      SkinMetricType.clarity: 1.00,
    },
    MaskModeType.intensiveCare: {
      SkinMetricType.delicacy: 1.00,
      SkinMetricType.hydration: 1.114,
      SkinMetricType.youthfulness: 1.00,
      SkinMetricType.clarity: 1.214, // 主增 ~95%
    },
    MaskModeType.lifting: {
      SkinMetricType.delicacy: 1.114,
      SkinMetricType.hydration: 1.00,
      SkinMetricType.youthfulness: 1.214, // 主增 ~95%
      SkinMetricType.clarity: 1.00,
    },
    MaskModeType.firming: {
      SkinMetricType.delicacy: 1.114,
      SkinMetricType.hydration: 1.00,
      SkinMetricType.youthfulness: 1.214, // 主增 ~95%
      SkinMetricType.clarity: 1.00,
    },
    MaskModeType.plumping: {
      SkinMetricType.delicacy: 1.214, // 主增 ~95%
      SkinMetricType.hydration: 1.00,
      SkinMetricType.youthfulness: 1.114,
      SkinMetricType.clarity: 1.00,
    },
    MaskModeType.rejuvenating: {
      SkinMetricType.delicacy: 1.00,
      SkinMetricType.hydration: 1.03,
      SkinMetricType.youthfulness: 1.214, // 主增 ~95%
      SkinMetricType.clarity: 1.114,
    },
  };

  // 综合模式权重基线 (动态接力时按阶段模式权重运行)
  static const Map<SkinMetricType, double> combinationWeights = {
    SkinMetricType.delicacy: 1.08,
    SkinMetricType.hydration: 1.12,
    SkinMetricType.youthfulness: 1.12,
    SkinMetricType.clarity: 1.08,
  };

  /// 获取当前模式下主推重点高亮的指标
  static bool isHighlighted({
    required MaskModeType mode,
    required SkinMetricType metric,
    bool isCombination = false,
  }) {
    if (isCombination) {
      return false; // 综合模式全维养护，不突出单一指标
    }
    switch (mode) {
      case MaskModeType.revitalizing:
        return metric == SkinMetricType.hydration;
      case MaskModeType.intensiveCare:
        return metric == SkinMetricType.clarity;
      case MaskModeType.lifting:
      case MaskModeType.firming:
        return metric == SkinMetricType.youthfulness;
      case MaskModeType.plumping:
        return metric == SkinMetricType.delicacy;
      case MaskModeType.rejuvenating:
        return metric == SkinMetricType.youthfulness || metric == SkinMetricType.clarity;
    }
  }

  /// 获取三阶段吸收系数 Kphase(t)
  static double getPhaseFactor(int elapsedSeconds) {
    if (elapsedSeconds < 240) {
      return 1.05; // 0 ~ 4 分钟：平稳充盈
    } else if (elapsedSeconds < 540) {
      return 1.00; // 4 ~ 9 分钟：匀速渗透
    } else {
      return 0.95; // 9 ~ 12 分钟：饱满巩固
    }
  }

  /// 获取档位增益系数 Kgear (1~10档: 0.96x ~ 1.05x，确保日常1~3档满程依然充盈)
  static double getGearFactor(int currentGear) {
    final clampedGear = currentGear.clamp(1, 10);
    return 0.96 + (clampedGear - 1) * 0.01;
  }
}

class SkinMetricData {
  final double smoothness; // 细腻度 (0.0 ~ 1.0)
  final double hydration; // 润泽度 (0.0 ~ 1.0)
  final double youthfulness; // 年轻度 (0.0 ~ 1.0)
  final double skinTone; // 匀净度 (0.0 ~ 1.0)

  // 别名支持
  double get delicacy => smoothness;
  double get clarity => skinTone;

  const SkinMetricData({
    this.smoothness = 0.0,
    this.hydration = 0.0,
    this.youthfulness = 0.0,
    this.skinTone = 0.0,
  });

  /// 初始微读数基线 (统一平滑起点 0.10)
  static const SkinMetricData initialBaseline = SkinMetricData(
    smoothness: 0.10,
    hydration: 0.10,
    youthfulness: 0.10,
    skinTone: 0.10,
  );

  /// 未开始状态的空柱 (0.0)
  static const SkinMetricData empty = SkinMetricData(
    smoothness: 0.0,
    hydration: 0.0,
    youthfulness: 0.0,
    skinTone: 0.0,
  );

  bool get isEmpty =>
      smoothness == 0.0 && hydration == 0.0 && youthfulness == 0.0 && skinTone == 0.0;

  double getMetric(SkinMetricType type) {
    switch (type) {
      case SkinMetricType.delicacy:
        return smoothness;
      case SkinMetricType.hydration:
        return hydration;
      case SkinMetricType.youthfulness:
        return youthfulness;
      case SkinMetricType.clarity:
        return skinTone;
    }
  }

  SkinMetricData copyWith({
    double? smoothness,
    double? hydration,
    double? youthfulness,
    double? skinTone,
  }) {
    return SkinMetricData(
      smoothness: smoothness ?? this.smoothness,
      hydration: hydration ?? this.hydration,
      youthfulness: youthfulness ?? this.youthfulness,
      skinTone: skinTone ?? this.skinTone,
    );
  }
}
