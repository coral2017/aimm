import 'package:flutter/material.dart';
export 'skin_metric_model.dart';

enum MaskModeType {
  // 紧致: 0x04, 档位: [13, 17, 22, 28, 33, 37, 41, 45, 49, 53]
  firming(
    0,
    0x04,
    'firming',
    Icons.all_inclusive_rounded,
    [13, 17, 22, 28, 33, 37, 41, 45, 49, 53],
  ),
  // 澎弹: 0x05, 档位: [13, 17, 22, 28, 33, 37, 41, 45, 49, 53]
  plumping(
    1,
    0x05,
    'plumping',
    Icons.water_drop_outlined,
    [13, 17, 22, 28, 33, 37, 41, 45, 49, 53],
  ),
  // 焕活: 0x07, 档位: [13, 17, 22, 28, 33, 37, 41, 45, 49, 53]
  rejuvenating(
    2,
    0x07,
    'rejuvenating',
    Icons.auto_awesome_rounded,
    [13, 17, 22, 28, 33, 37, 41, 45, 49, 53],
  ),
  // 瞬透: 0x08, 档位: [10, 14, 19, 26, 31, 36, 40, 44, 48, 52]
  intensiveCare(
    3,
    0x08,
    'intensiveCare',
    Icons.health_and_safety_outlined,
    [10, 14, 19, 26, 31, 36, 40, 44, 48, 52],
  ),
  // 提拉: 0x09, 档位: [10, 15, 19, 26, 31, 36, 40, 44, 48, 52]
  lifting(
    4,
    0x09,
    'lifting',
    Icons.north_east_rounded,
    [10, 15, 19, 26, 31, 36, 40, 44, 48, 52],
  ),
  // 活肌: 0x0B, 档位: [10, 15, 19, 26, 31, 36, 40, 44, 48, 52]
  revitalizing(
    5,
    0x0B,
    'revitalizing',
    Icons.spa_outlined,
    [10, 15, 19, 26, 31, 36, 40, 44, 48, 52],
  );

  final int id;
  final int firmwareValue;
  final String l10nKey;
  final IconData icon;
  final List<int> bleGears;

  const MaskModeType(
    this.id,
    this.firmwareValue,
    this.l10nKey,
    this.icon,
    this.bleGears,
  );

  int get startGear => bleGears.first;
  int get endGear => bleGears.last;

  /// 根据 App UI 的 1~10 档，计算下发给固件的通信档位
  int getBleGear(int uiGear) {
    final clamped = uiGear.clamp(1, bleGears.length);
    return bleGears[clamped - 1];
  }

  /// 从固件上报的通信档位反推 App UI 的 1~10 档
  int getUiGearFromBle(int bleGear) {
    final index = bleGears.indexOf(bleGear);
    if (index != -1) {
      return index + 1;
    }
    // 最近邻匹配保护
    int closestIndex = 0;
    int minDiff = (bleGears[0] - bleGear).abs();
    for (int i = 1; i < bleGears.length; i++) {
      final diff = (bleGears[i] - bleGear).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex + 1;
  }

  static MaskModeType fromId(int id) {
    return MaskModeType.values.firstWhere(
      (m) => m.id == id,
      orElse: () => MaskModeType.firming,
    );
  }

  static MaskModeType fromFirmwareValue(int fwValue) {
    return MaskModeType.values.firstWhere(
      (m) => m.firmwareValue == fwValue,
      orElse: () => MaskModeType.firming,
    );
  }
}
