import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimm/core/storage/ble_tx_log_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BleTxLogService Tests', () {
    test('Records TX command and exports clean text format', () async {
      final service = BleTxLogService.instance;
      await service.clearLogs();

      final mockPacket = Uint8List.fromList([
        0x45, 0xA2, 0x01, 0x00, 0x01, 0xA1, 0x04, 0x0D, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1E, 0x2C, 0xFF,
      ]);

      await service.recordCommand(
        mode: 0x04,
        gear: 13,
        isOpen: true,
        packet: mockPacket,
      );

      final logs = await service.getTodayLogs();
      expect(logs.length, equals(1));
      expect(logs[0].mode, equals(0x04));
      expect(logs[0].gear, equals(13));
      expect(logs[0].isOpen, isTrue);
      expect(logs[0].hexString.contains('45 A2'), isTrue);

      final exportedText = await service.exportFormattedText();
      expect(exportedText.contains('模式:0x04'), isTrue);
      expect(exportedText.contains('档位:13(0x0D)'), isTrue);
    });

    test('Daily rotation clears old logs from previous day', () async {
      final service = BleTxLogService.instance;
      final prefs = await SharedPreferences.getInstance();

      // Simulate logs from yesterday
      await prefs.setString('ble_tx_log_date', '2026-10-20');
      await prefs.setString('ble_tx_log_list', '[{"time":"2026-10-20T10:00:00.000","mode":4,"gear":13,"isOpen":true,"hex":"45 A2"}]');

      // Fetch today's logs - should automatically rotate and clear yesterday's records
      final logs = await service.getTodayLogs();
      expect(logs.isEmpty, isTrue);

      final currentDate = prefs.getString('ble_tx_log_date');
      final todayStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      expect(currentDate, equals(todayStr));
    });
  });
}
