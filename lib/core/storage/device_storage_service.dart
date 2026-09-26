import 'package:shared_preferences/shared_preferences.dart';
import '../ble/ble_device_info.dart';

class DeviceStorageService {
  static const String _keyBoundDeviceId = 'bound_device_id';
  static const String _keyBoundDeviceName = 'bound_device_name';

  static DeviceStorageService? _instance;
  static DeviceStorageService get instance => _instance ??= DeviceStorageService._();
  DeviceStorageService._();

  /// Save bound device to local persistent storage
  Future<void> saveBoundDevice(BleDeviceInfo device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBoundDeviceId, device.id);
    await prefs.setString(_keyBoundDeviceName, device.name);
  }

  /// Read bound device from local persistent storage
  Future<BleDeviceInfo?> getBoundDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyBoundDeviceId);
    final name = prefs.getString(_keyBoundDeviceName);

    if (id != null && id.isNotEmpty) {
      return BleDeviceInfo(
        id: id,
        name: (name != null && name.isNotEmpty) ? name : 'Alzmt Mask',
      );
    }
    return null;
  }

  /// Clear bound device (unbinding)
  Future<void> clearBoundDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBoundDeviceId);
    await prefs.remove(_keyBoundDeviceName);
  }

  /// Check if a device is currently bound
  Future<bool> hasBoundDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyBoundDeviceId);
    return id != null && id.isNotEmpty;
  }
}
