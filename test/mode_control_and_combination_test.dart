import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimm/core/ble/ble_device_info.dart';
import 'package:aimm/core/ble/ble_protocol.dart';
import 'package:aimm/features/control/models/mask_mode.dart';
import 'package:aimm/features/control/providers/mask_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Mode Control & Combination Logic Tests', () {
    test('Initial connection does not select any mode by default', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await controller.connect(testDevice);

      expect(controller.isConnected, isTrue);
      expect(controller.selectedMode, isNull);
      expect(controller.isCombinationActive, isFalse);
      expect(controller.isRunning, isFalse);

      // Attempting to start without a mode should be intercepted
      await controller.togglePower();
      expect(controller.isRunning, isFalse);

      controller.dispose();
    });

    test('Selecting mode, adjusting gear, and smooth mode switching while running', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await controller.connect(testDevice);

      // Select mode and start
      controller.setMode(MaskModeType.rejuvenating);
      expect(controller.selectedMode, MaskModeType.rejuvenating);

      await controller.togglePower();
      expect(controller.isRunning, isTrue);
      expect(controller.currentGear, 1);

      // Increase gear to 5
      await controller.setGear(5);
      expect(controller.currentGear, 5);

      // Smooth switch to another mode while running
      controller.setMode(MaskModeType.firming);
      // Must NOT pause running state
      expect(controller.isRunning, isTrue);
      expect(controller.selectedMode, MaskModeType.firming);
      // New mode starts at Gear 1 for user safety
      expect(controller.currentGear, 1);

      controller.dispose();
    });

    test('Anti-surge safety protection: pausing and resuming resets gear to 1', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await controller.connect(testDevice);

      controller.setMode(MaskModeType.lifting);
      await controller.togglePower();
      expect(controller.isRunning, isTrue);

      // User sets high gear (e.g., gear 8)
      await controller.setGear(8);
      expect(controller.currentGear, 8);

      // User pauses treatment
      await controller.togglePower();
      expect(controller.isRunning, isFalse);

      // User resumes treatment -> MUST reset to Gear 1
      await controller.togglePower();
      expect(controller.isRunning, isTrue);
      expect(controller.currentGear, 1);

      controller.dispose();
    });

    test('Combination mode cohesive 12-minute timeline and takeover', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await controller.connect(testDevice);

      controller.setMode(MaskModeType.rejuvenating);
      await controller.togglePower();
      expect(controller.isRunning, isTrue);

      // Switch to combination mode while running
      controller.switchToCombinationMode();
      expect(controller.isCombinationActive, isTrue);
      expect(controller.selectedMode, isNull);
      expect(controller.isRunning, isTrue);
      expect(controller.currentGear, 1);

      // Sub-mode stages map seamlessly to elapsed time
      // 0s elapsed -> stage 0: rejuvenating
      expect(controller.activeUnderlyingMode, MaskModeType.rejuvenating);

      // Pause and resume in combination mode also resets gear to 1
      await controller.setGear(6);
      expect(controller.currentGear, 6);
      await controller.togglePower(); // Pause
      expect(controller.isRunning, isFalse);
      await controller.togglePower(); // Resume
      expect(controller.isRunning, isTrue);
      expect(controller.currentGear, 1);

      controller.dispose();
    });

    test('MCU status sync and state resumption (续住时间)', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await controller.connect(testDevice);

      // Construct a report packet indicating MCU is already running at 10m35s, mode=0x07 (firming), gear=10 (BLE gear)
      const report = BleStatusReport(
        mode: 0x07,
        gear: 10,
        isOpen: true,
        battery: 95,
        workMinutes: 10,
        workSeconds: 35,
        contactStatus: 0x01,
      );

      // Simulate status report from MCU
      controller.handleStatusReportForTesting(report);

      expect(controller.isRunning, isTrue);
      expect(controller.selectedMode, MaskModeType.firming);
      expect(controller.remainingSecondsTotal, 10 * 60 + 35); // 635 seconds preserved
      expect(controller.remainingMinutes, 10);
      expect(controller.remainingSeconds, 35);

      controller.dispose();
    });
  });
}
