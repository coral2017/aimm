import 'package:flutter/material.dart';
export 'skin_metric_model.dart';

enum MaskModeType {
  // 焕肤: 摩皮-0x04, 起始档位: 6, 结束档位: 15 (共10档)
  rejuvenating(0, 0x04, 6, 15, 'rejuvenating', Icons.auto_awesome_rounded),
  // 增加弹性: 轻弹-0x05, 起始档位: 7, 结束档位: 16 (共10档)
  plumping(1, 0x05, 7, 16, 'plumping', Icons.water_drop_outlined),
  // 紧致: 拍打-0x07, 起始档位: 7, 结束档位: 16 (共10档)
  firming(2, 0x07, 7, 16, 'firming', Icons.all_inclusive_rounded),
  // 密集修护: 渗透-0x08, 起始档位: 3, 结束档位: 12 (共10档)
  intensiveCare(3, 0x08, 3, 12, 'intensiveCare', Icons.health_and_safety_outlined),
  // 赋活: 拍揉-0x09, 起始档位: 2, 结束档位: 11 (共10档)
  revitalizing(4, 0x09, 2, 11, 'revitalizing', Icons.spa_outlined),
  // 拉提: 轻叩-0x0B, 起始档位: 4, 结束档位: 13 (共10档)
  lifting(5, 0x0B, 4, 13, 'lifting', Icons.north_east_rounded);

  final int id;
  final int firmwareValue;
  final int startGear;
  final int endGear;
  final String l10nKey;
  final IconData icon;

  const MaskModeType(
    this.id,
    this.firmwareValue,
    this.startGear,
    this.endGear,
    this.l10nKey,
    this.icon,
  );

  /// 根据 App UI 的 1~10 档，计算下发给固件的通信档位
  int getBleGear(int uiGear) {
    final clamped = uiGear.clamp(1, 10);
    return startGear + (clamped - 1);
  }

  /// 从固件上报的通信档位反推 App UI 的 1~10 档
  int getUiGearFromBle(int bleGear) {
    return (bleGear - startGear + 1).clamp(1, 10);
  }

  static MaskModeType fromId(int id) {
    return MaskModeType.values.firstWhere(
      (m) => m.id == id,
      orElse: () => MaskModeType.rejuvenating,
    );
  }

  static MaskModeType fromFirmwareValue(int fwValue) {
    return MaskModeType.values.firstWhere(
      (m) => m.firmwareValue == fwValue,
      orElse: () => MaskModeType.rejuvenating,
    );
  }
}
