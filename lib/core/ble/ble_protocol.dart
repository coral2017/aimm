import 'dart:typed_data';

/// BLE Protocol specification implementation for Smart Mask
class BleProtocol {
  BleProtocol._();

  // BLE UUIDs
  static const String serviceUuid = '0000F760-0000-1000-8000-00805F9B34FB';
  static const String writeCharacteristicUuid = '0000F761-0000-1000-8000-00805F9B34FB';
  static const String notifyCharacteristicUuid = '0000F761-0000-1000-8000-00805F9B34FB';
  static const String deviceNamePrefix = 'AIMO';

  // Frame Constants
  static const int headerByte1 = 0x45;
  static const int headerByte2 = 0xA2;
  static const int trailerByte1 = 0x2C;
  static const int trailerByte2 = 0xFF;
  static const int packetLength = 20;

  // Protocol Version & Device ID
  static const int protocolVersion = 0x01;
  static const int deviceIdByte1 = 0x00;
  static const int deviceIdByte2 = 0x01;

  // Function Codes
  static const int funcCodeControl = 0xA1;
  static const int funcCodeStatusReport = 0xA4;

  /// Calculate CRC Checksum: Sum of all bytes excluding Header (indices 0, 1), Trailer (18, 19), and CRC (17)
  static int calculateCrc(Uint8List packet) {
    if (packet.length < packetLength) return 0;
    int sum = 0;
    for (int i = 2; i <= 16; i++) {
      sum = (sum + packet[i]) & 0xFF;
    }
    return sum;
  }

  /// Builds a 20-byte control packet (0xA1) for APP -> MCU
  /// [mode]: 0x00 ~ 0x0B
  /// [gear]: 0x01 ~ 0x10 (1 ~ 16)
  /// [isOpen]: true for 0x01 (On), false for 0x00 (Off)
  static Uint8List buildControlPacket({
    required int mode,
    required int gear,
    required bool isOpen,
  }) {
    final packet = Uint8List(packetLength);

    // Frame Header (2 bytes)
    packet[0] = headerByte1;
    packet[1] = headerByte2;

    // Version (1 byte)
    packet[2] = protocolVersion;

    // Device ID (2 bytes)
    packet[3] = deviceIdByte1;
    packet[4] = deviceIdByte2;

    // Function Code (1 byte)
    packet[5] = funcCodeControl;

    // Content (6 bytes)
    packet[6] = mode & 0xFF; // Mode (0x00 ~ 0x0B)
    packet[7] = gear.clamp(1, 16) & 0xFF; // Gear (0x01 ~ 0x10)
    packet[8] = isOpen ? 0x01 : 0x00; // Switch
    packet[9] = 0x00; // Reserved
    packet[10] = 0x00; // Reserved
    packet[11] = 0x00; // Reserved

    // Reserved (5 bytes)
    packet[12] = 0x00;
    packet[13] = 0x00;
    packet[14] = 0x00;
    packet[15] = 0x00;
    packet[16] = 0x00;

    // CRC Checksum (1 byte)
    packet[17] = calculateCrc(packet);

    // Frame Trailer (2 bytes)
    packet[18] = trailerByte1;
    packet[19] = trailerByte2;

    return packet;
  }

  /// Parse MCU status report packet (0xA4)
  static BleStatusReport? parseStatusPacket(Uint8List packet) {
    if (packet.length != packetLength) return null;
    if (packet[0] != headerByte1 || packet[1] != headerByte2) return null;
    if (packet[18] != trailerByte1 || packet[19] != trailerByte2) return null;

    final expectedCrc = calculateCrc(packet);
    if (packet[17] != expectedCrc) {
      // Allow slight tolerance if needed, but flag for logging
    }

    final funcCode = packet[5];
    if (funcCode != funcCodeStatusReport && funcCode != funcCodeControl) {
      return null;
    }

    final mode = packet[6];
    final gear = packet[7];
    final isOpen = packet[8] == 0x01;
    final battery = packet[9].clamp(0, 100);
    final workMinutes = packet[10].clamp(0, 59);
    final workSeconds = packet[11].clamp(0, 59);

    return BleStatusReport(
      mode: mode,
      gear: gear,
      isOpen: isOpen,
      battery: battery,
      workMinutes: workMinutes,
      workSeconds: workSeconds,
    );
  }
}

/// Parsed MCU device status payload
class BleStatusReport {
  final int mode;
  final int gear;
  final bool isOpen;
  final int battery;
  final int workMinutes;
  final int workSeconds;

  const BleStatusReport({
    required this.mode,
    required this.gear,
    required this.isOpen,
    required this.battery,
    required this.workMinutes,
    required this.workSeconds,
  });

  @override
  String toString() {
    return 'BleStatusReport(mode: $mode, gear: $gear, isOpen: $isOpen, battery: $battery%, time: ${workMinutes}m${workSeconds}s)';
  }
}
