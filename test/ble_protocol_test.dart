import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/ble/ble_protocol.dart';
import '../lib/features/control/models/mask_mode.dart';

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
    });

    test('MaskModeType enum mapping', () {
      expect(MaskModeType.fromId(0), equals(MaskModeType.rejuvenating));
      expect(MaskModeType.fromId(1), equals(MaskModeType.firming));
      expect(MaskModeType.fromId(2), equals(MaskModeType.lifting));
      expect(MaskModeType.fromId(3), equals(MaskModeType.intensiveCare));
      expect(MaskModeType.fromId(4), equals(MaskModeType.revitalizing));
      expect(MaskModeType.fromId(5), equals(MaskModeType.plumping));
    });
  });
}
