import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimm/core/ble/ble_device_info.dart';
import 'package:aimm/core/storage/device_storage_service.dart';
import 'package:aimm/features/control/providers/mask_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeviceStorageService Tests', () {
    test('save, get, and clear bound device', () async {
      final storage = DeviceStorageService.instance;
      expect(await storage.hasBoundDevice(), isFalse);
      expect(await storage.getBoundDevice(), isNull);

      const device = BleDeviceInfo(id: 'TEST-MAC-01', name: 'Mask-Test');
      await storage.saveBoundDevice(device);

      expect(await storage.hasBoundDevice(), isTrue);
      final retrieved = await storage.getBoundDevice();
      expect(retrieved?.id, 'TEST-MAC-01');
      expect(retrieved?.name, 'Mask-Test');

      await storage.clearBoundDevice();
      expect(await storage.hasBoundDevice(), isFalse);
      expect(await storage.getBoundDevice(), isNull);
    });
  });

  group('MaskController Binding & Unbind Lifecycle Tests', () {
    test('connecting device binds and persists it', () async {
      final controller = MaskController();
      expect(controller.isBound, isFalse);
      expect(controller.isConnected, isFalse);

      const testDevice = BleDeviceInfo(
        id: 'EF0A92E5-A99C-EC12-BADF-9E7ADE45FC29',
        name: 'AIMO Mask V2',
      );

      final success = await controller.connect(testDevice);
      expect(success, isTrue);
      expect(controller.isConnected, isTrue);
      expect(controller.isBound, isTrue);
      expect(controller.boundDevice?.id, testDevice.id);

      final saved = await DeviceStorageService.instance.getBoundDevice();
      expect(saved?.id, testDevice.id);

      controller.dispose();
    });

    test('unbinding clears persistent storage and stops auto-reconnect', () async {
      const testDevice = BleDeviceInfo(
        id: 'EF0A92E5-A99C-EC12-BADF-9E7ADE45FC29',
        name: 'AIMO Mask V2',
      );
      await DeviceStorageService.instance.saveBoundDevice(testDevice);

      final controller = MaskController();
      // Allow async loadBoundDevice to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isBound, isTrue);
      expect(controller.boundDevice?.id, testDevice.id);

      // Now unbind
      await controller.unbindCurrentDevice();

      expect(controller.isBound, isFalse);
      expect(controller.boundDevice, isNull);
      expect(controller.isConnected, isFalse);
      expect(controller.isAutoReconnecting, isFalse);

      final saved = await DeviceStorageService.instance.getBoundDevice();
      expect(saved, isNull);

      controller.dispose();
    });
  });
}
