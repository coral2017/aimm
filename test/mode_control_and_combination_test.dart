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
      // 0s elapsed -> stage 0: firming (first mode in values sequence)
      expect(controller.activeUnderlyingMode, MaskModeType.firming);

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

      // Construct a report packet indicating MCU is already running at 10m35s, mode=0x04 (firming), gear=22 (BLE gear -> UI gear 3)
      const report = BleStatusReport(
        mode: 0x04,
        gear: 22,
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
      expect(controller.currentGear, 3);
      expect(controller.remainingSecondsTotal, 10 * 60 + 35); // 635 seconds preserved
      expect(controller.remainingMinutes, 10);
      expect(controller.remainingSeconds, 35);

      controller.dispose();
    });

    test('Saved Mode Presets: save, isCurrentSaved check, deduplication, and applyPresetAndStart', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');

      await controller.connect(testDevice);

      expect(controller.isCurrentSaved, false);

      // Select mode and gear
      controller.setMode(MaskModeType.firming);
      await controller.togglePower(); // Start running to allow adjusting gear
      await controller.setGear(3);

      expect(controller.isCurrentSaved, false);

      // Save preset
      await controller.savePreset(mode: MaskModeType.firming, gear: 3);
      expect(controller.savedPresets.length, 1);
      expect(controller.isCurrentSaved, true);

      // Deduplication: saving same mode and gear should not duplicate
      await controller.savePreset(mode: MaskModeType.firming, gear: 3);
      expect(controller.savedPresets.length, 1);

      // Adjust gear to 4 -> isCurrentSaved becomes false
      await controller.setGear(4);
      expect(controller.isCurrentSaved, false);

      // Save another preset for lifting gear 5
      await controller.savePreset(mode: MaskModeType.lifting, gear: 5);
      expect(controller.savedPresets.length, 2);

      // Apply first preset (firming gear 3) -> should set mode, gear 3, and ensure power is on
      final firstPreset = controller.savedPresets.firstWhere((p) => p.mode == MaskModeType.firming);
      await controller.applyPresetAndStart(firstPreset);

      expect(controller.selectedMode, MaskModeType.firming);
      expect(controller.currentGear, 3);
      expect(controller.isPowerOn, true);
      expect(controller.isCurrentSaved, true);

      // Delete preset
      await controller.deletePreset(firstPreset.id);
      expect(controller.savedPresets.length, 1);
      expect(controller.isCurrentSaved, false);

      // Combination Mode Saving (WeChat Mini Program parity)
      await controller.switchToCombinationMode();
      await controller.setGear(2);
      expect(controller.isCombinationActive, true);
      expect(controller.isCurrentSaved, false);

      // Save combination preset
      await controller.savePreset(isCombination: true, gear: 2);
      expect(controller.isCurrentSaved, true);
      expect(controller.savedPresets.length, 2);
      final comboPreset = controller.savedPresets.firstWhere((p) => p.isCombination);
      expect(comboPreset.isCombination, true);
      expect(comboPreset.gear, 2);

      // Switch away and apply combination preset
      controller.setMode(MaskModeType.plumping);
      expect(controller.isCombinationActive, false);
      await controller.applyPresetAndStart(comboPreset);
      expect(controller.isCombinationActive, true);
      expect(controller.currentGear, 2);

      controller.dispose();
    });

    test('Direct discrete single packet dispatch matching WeChat Mini Program', () async {
      final controller = MaskController();
      const testDevice = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await controller.connect(testDevice);

      controller.setMode(MaskModeType.firming); // Start gear is 13
      await controller.togglePower(); // Starts at gear 13
      expect(controller.currentGear, 1);
      expect(controller.dispatchedBleGear, 13);

      // Transition to gear 3 (Firming UI gear 3 -> BLE gear 22)
      // Dispatches discrete target 22 directly in a single packet matching Mini Program
      await controller.setGear(3);
      expect(controller.currentGear, 3);
      expect(controller.dispatchedBleGear, 22);

      controller.dispose();
    });

    test('Global intensity offset attenuation adjustment', () {
      try {
        IntensityConfig.globalOffset = 0;
        // Firming base gears: [13, 17, 22, 28, 33, 37, 41, 45, 49, 53]
        expect(MaskModeType.firming.getBleGear(1), 13);
        expect(MaskModeType.firming.getBleGear(2), 17);
        expect(MaskModeType.firming.getBleGear(3), 22);

        // Attenuate globally by -2 steps
        IntensityConfig.globalOffset = -2;
        expect(MaskModeType.firming.getBleGear(1), 11);
        expect(MaskModeType.firming.getBleGear(2), 15);
        expect(MaskModeType.firming.getBleGear(3), 20);

        // Reverse lookup clamp protection
        expect(MaskModeType.firming.getUiGearFromBle(11), 1);
      } finally {
        IntensityConfig.globalOffset = 0; // Restore default
      }
    });
  });
}

