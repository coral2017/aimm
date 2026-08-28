import 'dart:typed_data';
import 'ble_device_info.dart';
import 'ble_protocol.dart';

enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  disconnecting,
}

abstract class IBleService {
  Stream<BleConnectionState> get connectionStateStream;
  BleConnectionState get currentConnectionState;
  Stream<List<BleDeviceInfo>> get scanResultsStream;
  Stream<BleStatusReport> get statusReportStream;
  BleDeviceInfo? get connectedDevice;

  Future<void> startScan({Duration timeout = const Duration(seconds: 8)});
  Future<void> stopScan();
  Future<bool> connect(BleDeviceInfo device);
  Future<void> disconnect();
  Future<bool> sendControlPacket(Uint8List packet);
  void dispose();
}
