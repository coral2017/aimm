import 'package:flutter/material.dart';
export 'skin_metric_model.dart';

enum MaskModeType {
  rejuvenating(0, 'rejuvenating', Icons.auto_awesome_rounded),
  firming(1, 'firming', Icons.all_inclusive_rounded),
  lifting(2, 'lifting', Icons.north_east_rounded),
  intensiveCare(3, 'intensiveCare', Icons.health_and_safety_outlined),
  revitalizing(4, 'revitalizing', Icons.spa_outlined),
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
