import 'mask_mode.dart';

enum SkinMetricType {
  delicacy, // 细腻度
  hydration, // 润泽度
  youthfulness, // 年轻度
  clarity, // 匀净度
}

class SkinMetricConfig {
  static const double baseTotalGrowth = 0.50; // 累计总增量
  static const int totalSeconds = 720; // 12 分钟 (720秒)
  static const double vBase = baseTotalGrowth / totalSeconds; // 约 0.000694/秒

  // 模式权重映射表 (每项归一化校验总和为 4.0)
  static const Map<MaskModeType, Map<SkinMetricType, double>> modeWeights = {
    MaskModeType.revitalizing: {
      SkinMetricType.delicacy: 1.0,
      SkinMetricType.hydration: 1.8, // 主增
      SkinMetricType.youthfulness: 0.5,
      SkinMetricType.clarity: 0.7,
    },
    MaskModeType.intensiveCare: {
      SkinMetricType.delicacy: 0.9,
      SkinMetricType.hydration: 1.0,
      SkinMetricType.youthfulness: 0.5,
      SkinMetricType.clarity: 1.6, // 主增
    },
    MaskModeType.lifting: {
      SkinMetricType.delicacy: 1.0,
      SkinMetricType.hydration: 0.5,
      SkinMetricType.youthfulness: 1.8, // 主增
      SkinMetricType.clarity: 0.7,
    },
    MaskModeType.firming: {
      SkinMetricType.delicacy: 1.2,
      SkinMetricType.hydration: 0.5,
      SkinMetricType.youthfulness: 1.6, // 主增
      SkinMetricType.clarity: 0.7,
    },
    MaskModeType.plumping: {
      SkinMetricType.delicacy: 1.6, // 主增
      SkinMetricType.hydration: 1.3,
      SkinMetricType.youthfulness: 0.6,
      SkinMetricType.clarity: 0.5,
    },
    MaskModeType.rejuvenating: {
      SkinMetricType.delicacy: 0.7,
      SkinMetricType.hydration: 0.7,
      SkinMetricType.youthfulness: 1.3, // 主增
      SkinMetricType.clarity: 1.3, // 主增
    },
  };

  // 综合模式权重 (全维平衡养护)
  static const Map<SkinMetricType, double> combinationWeights = {
    SkinMetricType.delicacy: 1.0,
    SkinMetricType.hydration: 1.0,
    SkinMetricType.youthfulness: 1.0,
    SkinMetricType.clarity: 1.0,
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
      return 1.30; // 0 ~ 4 分钟：快速吸收期
    } else if (elapsedSeconds < 540) {
      return 1.00; // 4 ~ 9 分钟：深层滋养期
    } else {
      return 0.70; // 9 ~ 12 分钟：饱满巩固期
    }
  }

  /// 获取档位增益系数 Kgear
  static double getGearFactor(int currentGear) {
    final clampedGear = currentGear.clamp(1, 16);
    return 1.0 + (clampedGear - 1) * 0.05;
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

  /// 初始轻度伪随机基线 (0.38 ~ 0.44)
  static const SkinMetricData initialBaseline = SkinMetricData(
    smoothness: 0.40,
    hydration: 0.42,
    youthfulness: 0.38,
    skinTone: 0.41,
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
