import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'ble_device_info.dart';
import 'ble_mock_service.dart';
import 'ble_protocol.dart';
import 'ble_real_service.dart';
import 'ble_service_interface.dart';

/// Unified BLE Manager coordinating active BLE service (Real vs Mock)
class BleManager {
  static final BleManager instance = BleManager._internal();
  BleManager._internal() {
    _initService();
  }

  late IBleService _service;
  bool _isMockMode = false;

  void _initService() {
    // If running on Web or Desktop, or forced mock, use Mock service
    if (kIsWeb) {
      _isMockMode = true;
      _service = BleMockService();
    } else {
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          _isMockMode = false;
          _service = BleRealService();
        } else {
          _isMockMode = true;
          _service = BleMockService();
        }
      } catch (_) {
        _isMockMode = true;
        _service = BleMockService();
      }
    }
  }

  IBleService get service => _service;
  bool get isMockMode => _isMockMode;

  /// Force toggle between Mock and Real service for testing
  void setMockMode(bool enableMock) {
    if (_isMockMode == enableMock) return;
    _service.dispose();
    _isMockMode = enableMock;
    _service = enableMock ? BleMockService() : BleRealService();
  }

  Stream<BleConnectionState> get connectionStateStream => _service.connectionStateStream;
  BleConnectionState get currentConnectionState => _service.currentConnectionState;
  Stream<List<BleDeviceInfo>> get scanResultsStream => _service.scanResultsStream;
  Stream<BleStatusReport> get statusReportStream => _service.statusReportStream;
  BleDeviceInfo? get connectedDevice => _service.connectedDevice;

  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) =>
      _service.startScan(timeout: timeout);

  Future<void> stopScan() => _service.stopScan();

  Future<bool> connect(BleDeviceInfo device) => _service.connect(device);

  Future<void> disconnect() => _service.disconnect();

  Future<bool> sendControl({
    required int mode,
    required int gear,
    required bool isOpen,
  }) {
    final packet = BleProtocol.buildControlPacket(
      mode: mode,
      gear: gear,
      isOpen: isOpen,
    );
    return _service.sendControlPacket(packet);
  }
}
