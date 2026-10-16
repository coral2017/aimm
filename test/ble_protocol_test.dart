import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:aimm/core/ble/ble_protocol.dart';
import 'package:aimm/features/control/models/mask_mode.dart';

void main() {
  group('BleProtocol Tests', () {
    test('buildControlPacket creates valid 20-byte packet', () {
      final packet = BleProtocol.buildControlPacket(
        mode: 0x00, // Rejuvenating
        gear: 3, // Level 3
        isOpen: true, // Power On
      );

      // Verify length
      expect(packet.length, equals(20));

      // Verify Header: 45 A2
      expect(packet[0], equals(0x45));
      expect(packet[1], equals(0xA2));

      // Verify Version: 01
      expect(packet[2], equals(0x01));

      // Verify Device ID: 00 01
      expect(packet[3], equals(0x00));
      expect(packet[4], equals(0x01));

      // Verify Func Code: A1
      expect(packet[5], equals(0xA1));

      // Verify Content: Mode 0x00, Gear 0x03, Switch 0x01
      expect(packet[6], equals(0x00));
      expect(packet[7], equals(0x03));
      expect(packet[8], equals(0x01));
      expect(packet[9], equals(0x00));
      expect(packet[10], equals(0x00));
      expect(packet[11], equals(0x00));

      // Verify Reserved 5 bytes (indices 12..16)
      for (int i = 12; i <= 16; i++) {
        expect(packet[i], equals(0x00));
      }

      // Verify CRC: sum of bytes 2..16
      int expectedCrc = 0;
      for (int i = 2; i <= 16; i++) {
        expectedCrc = (expectedCrc + packet[i]) & 0xFF;
      }
      expect(packet[17], equals(expectedCrc));

      // Verify Trailer: 2C FF
      expect(packet[18], equals(0x2C));
      expect(packet[19], equals(0xFF));
    });

    test('buildControlPacket preserves high gear values without 16 clamping', () {
      final packet = BleProtocol.buildControlPacket(
        mode: 0x07, // Rejuvenating
        gear: 53, // Gear 10 communication value = 53 (0x35)
        isOpen: true,
      );
      expect(packet[7], equals(53));
      expect(packet[7], equals(0x35));
    });

    test('parseStatusPacket parses MCU 0xA4 report correctly', () {
      // Create a mock MCU A4 status packet
      final packet = Uint8List(20);
      packet[0] = 0x45;
      packet[1] = 0xA2;
      packet[2] = 0x01; // version
      packet[3] = 0x00; // dev id 1
      packet[4] = 0x01; // dev id 2
      packet[5] = 0xA4; // func code status report
      packet[6] = 0x01; // mode: Firming (1)
      packet[7] = 0x05; // gear: 5
      packet[8] = 0x01; // switch: on (1)
      packet[9] = 0x50; // battery: 80% (0x50)
      packet[10] = 0x0C; // work minutes: 12 (0x0C)
      packet[11] = 0x1E; // work seconds: 30 (0x1E)
      // reserved bytes 12..16
      for (int i = 12; i <= 16; i++) {
        packet[i] = 0x00;
      }
      // CRC
      packet[17] = BleProtocol.calculateCrc(packet);
      // Trailer
      packet[18] = 0x2C;
      packet[19] = 0xFF;

      final report = BleProtocol.parseStatusPacket(packet);
      expect(report, isNotNull);
      expect(report!.mode, equals(1));
      expect(report.gear, equals(5));
      expect(report.isOpen, isTrue);
      expect(report.battery, equals(80));
      expect(report.workMinutes, equals(12));
      expect(report.workSeconds, equals(30));
      expect(report.contactStatus, equals(0));
    });

    test('MaskModeType firmware values and gear mappings', () {
      // 紧致: 0x04, 13~53
      expect(MaskModeType.firming.firmwareValue, equals(0x04));
      expect(MaskModeType.firming.startGear, equals(13));
      expect(MaskModeType.firming.endGear, equals(53));
      expect(MaskModeType.firming.getBleGear(1), equals(13));
      expect(MaskModeType.firming.getBleGear(2), equals(17));
      expect(MaskModeType.firming.getBleGear(5), equals(33));
      expect(MaskModeType.firming.getBleGear(10), equals(53));
      expect(MaskModeType.firming.getUiGearFromBle(13), equals(1));
      expect(MaskModeType.firming.getUiGearFromBle(17), equals(2));
      expect(MaskModeType.firming.getUiGearFromBle(53), equals(10));

      // 澎弹: 0x05, 13~53
      expect(MaskModeType.plumping.firmwareValue, equals(0x05));
      expect(MaskModeType.plumping.startGear, equals(13));
      expect(MaskModeType.plumping.endGear, equals(53));
      expect(MaskModeType.plumping.getBleGear(1), equals(13));
      expect(MaskModeType.plumping.getBleGear(10), equals(53));

      // 焕活: 0x07, 13~53
      expect(MaskModeType.rejuvenating.firmwareValue, equals(0x07));
      expect(MaskModeType.rejuvenating.startGear, equals(13));
      expect(MaskModeType.rejuvenating.endGear, equals(53));
      expect(MaskModeType.rejuvenating.getBleGear(1), equals(13));
      expect(MaskModeType.rejuvenating.getBleGear(10), equals(53));

      // 瞬透: 0x08, 10~52 (2档为 14)
      expect(MaskModeType.intensiveCare.firmwareValue, equals(0x08));
      expect(MaskModeType.intensiveCare.startGear, equals(10));
      expect(MaskModeType.intensiveCare.endGear, equals(52));
      expect(MaskModeType.intensiveCare.getBleGear(1), equals(10));
      expect(MaskModeType.intensiveCare.getBleGear(2), equals(14));
      expect(MaskModeType.intensiveCare.getBleGear(10), equals(52));
      expect(MaskModeType.intensiveCare.getUiGearFromBle(14), equals(2));

      // 提拉: 0x09, 10~52 (2档为 15)
      expect(MaskModeType.lifting.firmwareValue, equals(0x09));
      expect(MaskModeType.lifting.startGear, equals(10));
      expect(MaskModeType.lifting.endGear, equals(52));
      expect(MaskModeType.lifting.getBleGear(1), equals(10));
      expect(MaskModeType.lifting.getBleGear(2), equals(15));
      expect(MaskModeType.lifting.getBleGear(10), equals(52));

      // 活肌: 0x0B, 10~52 (2档为 15)
      expect(MaskModeType.revitalizing.firmwareValue, equals(0x0B));
      expect(MaskModeType.revitalizing.startGear, equals(10));
      expect(MaskModeType.revitalizing.endGear, equals(52));
      expect(MaskModeType.revitalizing.getBleGear(1), equals(10));
      expect(MaskModeType.revitalizing.getBleGear(2), equals(15));
      expect(MaskModeType.revitalizing.getBleGear(10), equals(52));
    });
  });
}
