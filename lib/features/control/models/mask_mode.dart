import 'package:flutter/material.dart';

enum MaskModeType {
  rejuvenating(0, 'rejuvenating', Icons.hub_outlined),
  firming(1, 'firming', Icons.lightbulb_outline),
  lifting(2, 'lifting', Icons.waves),
  intensiveCare(3, 'intensiveCare', Icons.fitness_center),
  revitalizing(4, 'revitalizing', Icons.sentiment_satisfied_alt),
  plumping(5, 'plumping', Icons.water_drop_outlined);

  final int id;
  final String l10nKey;
  final IconData icon;

  const MaskModeType(this.id, this.l10nKey, this.icon);

  static MaskModeType fromId(int id) {
    return MaskModeType.values.firstWhere(
      (m) => m.id == id,
      orElse: () => MaskModeType.rejuvenating,
    );
  }
}

class SkinMetricData {
  final double smoothness; // 0.0 ~ 1.0
  final double hydration; // 0.0 ~ 1.0
  final double youthfulness; // 0.0 ~ 1.0
  final double skinTone; // 0.0 ~ 1.0

  const SkinMetricData({
    this.smoothness = 0.72,
    this.hydration = 0.58,
    this.youthfulness = 0.45,
    this.skinTone = 0.86,
  });

  static const SkinMetricData empty = SkinMetricData(
    smoothness: 0.0,
    hydration: 0.0,
    youthfulness: 0.0,
    skinTone: 0.0,
  );
}
