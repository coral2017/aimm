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
      // 焕肤: 0x04, 6~15
      expect(MaskModeType.rejuvenating.firmwareValue, equals(0x04));
      expect(MaskModeType.rejuvenating.startGear, equals(6));
      expect(MaskModeType.rejuvenating.endGear, equals(15));
      expect(MaskModeType.rejuvenating.getBleGear(1), equals(6));
      expect(MaskModeType.rejuvenating.getBleGear(10), equals(15));

      // 增加弹性: 0x05, 7~16
      expect(MaskModeType.plumping.firmwareValue, equals(0x05));
      expect(MaskModeType.plumping.startGear, equals(7));
      expect(MaskModeType.plumping.endGear, equals(16));
      expect(MaskModeType.plumping.getBleGear(1), equals(7));
      expect(MaskModeType.plumping.getBleGear(10), equals(16));

      // 紧致: 0x07, 7~16
      expect(MaskModeType.firming.firmwareValue, equals(0x07));
      expect(MaskModeType.firming.startGear, equals(7));
      expect(MaskModeType.firming.endGear, equals(16));
      expect(MaskModeType.firming.getBleGear(1), equals(7));
      expect(MaskModeType.firming.getBleGear(10), equals(16));

      // 密集修护: 0x08, 3~12
      expect(MaskModeType.intensiveCare.firmwareValue, equals(0x08));
      expect(MaskModeType.intensiveCare.startGear, equals(3));
      expect(MaskModeType.intensiveCare.endGear, equals(12));
      expect(MaskModeType.intensiveCare.getBleGear(1), equals(3));
      expect(MaskModeType.intensiveCare.getBleGear(10), equals(12));

      // 赋活: 0x09, 2~11
      expect(MaskModeType.revitalizing.firmwareValue, equals(0x09));
      expect(MaskModeType.revitalizing.startGear, equals(2));
      expect(MaskModeType.revitalizing.endGear, equals(11));
      expect(MaskModeType.revitalizing.getBleGear(1), equals(2));
      expect(MaskModeType.revitalizing.getBleGear(10), equals(11));

      // 拉提: 0x0B, 4~13
      expect(MaskModeType.lifting.firmwareValue, equals(0x0B));
      expect(MaskModeType.lifting.startGear, equals(4));
      expect(MaskModeType.lifting.endGear, equals(13));
      expect(MaskModeType.lifting.getBleGear(1), equals(4));
      expect(MaskModeType.lifting.getBleGear(10), equals(13));
    });
  });
}
