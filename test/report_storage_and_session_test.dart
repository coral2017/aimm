import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimm/core/ble/ble_device_info.dart';
import 'package:aimm/core/storage/report_storage_service.dart';
import 'package:aimm/features/control/models/mask_mode.dart';
import 'package:aimm/features/control/providers/mask_controller.dart';
import 'package:aimm/features/report/models/skincare_report_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SkincareReportModel & ReportStorageService Tests', () {
    test('SkincareReportModel serialization and deserialization', () {
      final now = DateTime.now();
      final report = SkincareReportModel(
        id: 'report_001',
        startTime: now.subtract(const Duration(minutes: 12)),
        endTime: now,
        actualDurationSeconds: 720,
        modeKey: 'rejuvenating',
        modeName: '焕活',
        maxGear: 6,
        avgGear: 4.5,
        smoothness: 0.88,
        hydration: 0.92,
        youthfulness: 0.85,
        skinTone: 0.89,
        score: 89,
        isCompleted: true,
      );

      final map = report.toMap();
      final restored = SkincareReportModel.fromMap(map);

      expect(restored.id, 'report_001');
      expect(restored.actualDurationSeconds, 720);
      expect(restored.modeKey, 'rejuvenating');
      expect(restored.modeName, '焕活');
      expect(restored.maxGear, 6);
      expect(restored.avgGear, 4.5);
      expect(restored.score, 89);
      expect(restored.isCompleted, isTrue);
      expect(restored.formattedDuration, '12 min');
    });

    test('ReportStorageService save, retrieve, delete, and clear', () async {
      final storage = ReportStorageService.instance;
      expect(await storage.getReports(), isEmpty);

      final now = DateTime.now();
      final report1 = SkincareReportModel(
        id: 'rep_1',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 48)),
        actualDurationSeconds: 720,
        modeKey: 'rejuvenating',
        modeName: '焕活',
        maxGear: 5,
        avgGear: 4.0,
        smoothness: 0.85,
        hydration: 0.90,
        youthfulness: 0.80,
        skinTone: 0.85,
        score: 85,
        isCompleted: true,
      );

      final report2 = SkincareReportModel(
        id: 'rep_2',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.subtract(const Duration(minutes: 20)),
        actualDurationSeconds: 600,
        modeKey: 'combination',
        modeName: '综合模式',
        maxGear: 8,
        avgGear: 5.5,
        smoothness: 0.82,
        hydration: 0.86,
        youthfulness: 0.88,
        skinTone: 0.84,
        score: 85,
        isCompleted: false,
      );

      await storage.saveReport(report1);
      await storage.saveReport(report2);

      final list = await storage.getReports();
      expect(list.length, 2);
      // Newest report first
      expect(list.first.id, 'rep_2');
      expect(list.last.id, 'rep_1');

      // Delete rep_1
      await storage.deleteReport('rep_1');
      final listAfterDelete = await storage.getReports();
      expect(listAfterDelete.length, 1);
      expect(listAfterDelete.first.id, 'rep_2');

      // Clear all
      await storage.clearReports();
      expect(await storage.getReports(), isEmpty);
    });
  });

  group('Treatment Session Lifecycle & Extreme Case Tests', () {
    test('Noise filtering: treatment run < 60s is discarded', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-DEV', name: 'AIMO Mask');
      await controller.connect(testDevice);

      controller.setMode(MaskModeType.rejuvenating);
      await controller.togglePower(); // Start
      expect(controller.isRunning, isTrue);

      // Simulate 30s running (< 60s)
      await controller.finalizeAndSaveSessionForTesting(isCompleted: false);

      final reports = await ReportStorageService.instance.getReports();
      expect(reports, isEmpty, reason: 'Treatment under 60 seconds should be discarded as noise');

      controller.dispose();
    });

    test('Valid partial treatment: run >= 60s is saved with isCompleted=false', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-DEV', name: 'AIMO Mask');
      await controller.connect(testDevice);

      controller.setMode(MaskModeType.firming);
      await controller.togglePower(); // Start
      await controller.setGear(5);

      // Simulate 180s (3 minutes) running
      controller.simulateSessionSecondsForTesting(180);
      expect(controller.sessionAccumulatedSeconds, 180);

      // Trigger finalize (e.g. user unbinds or stops midway)
      await controller.finalizeAndSaveSessionForTesting(isCompleted: false);

      final reports = await ReportStorageService.instance.getReports();
      expect(reports.length, 1);
      final saved = reports.first;
      expect(saved.isCompleted, isFalse);
      expect(saved.actualDurationSeconds, 180);
      expect(saved.modeKey, 'firming');

      controller.dispose();
    });

    test('Full 12-minute treatment automatically saves completed report', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-DEV', name: 'AIMO Mask');
      await controller.connect(testDevice);

      controller.setMode(MaskModeType.rejuvenating);
      await controller.togglePower(); // Start
      controller.simulateSessionSecondsForTesting(720);

      // Finalize full treatment
      await controller.finalizeAndSaveSessionForTesting(isCompleted: true);

      final reports = await ReportStorageService.instance.getReports();
      expect(reports.isNotEmpty, isTrue);
      final saved = reports.first;
      expect(saved.isCompleted, isTrue);
      expect(saved.actualDurationSeconds, 720);
      expect(saved.formattedDuration, '12 min');

      controller.dispose();
    });
  });
}
