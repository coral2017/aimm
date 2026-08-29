import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_device_info.dart';
import 'ble_protocol.dart';
import 'ble_service_interface.dart';

/// Real BLE service utilizing FlutterBluePlus
class BleRealService implements IBleService {
  final _connectionStateController = StreamController<BleConnectionState>.broadcast();
  final _scanResultsController = StreamController<List<BleDeviceInfo>>.broadcast();
  final _statusReportController = StreamController<BleStatusReport>.broadcast();

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _connectedDevice;
  BluetoothDevice? _activeDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  StreamSubscription? _scanSub;
  StreamSubscription? _deviceStateSub;
  StreamSubscription? _notifySub;

  @override
  Stream<BleConnectionState> get connectionStateStream => _connectionStateController.stream;

  @override
  BleConnectionState get currentConnectionState => _connectionState;

  @override
  Stream<List<BleDeviceInfo>> get scanResultsStream => _scanResultsController.stream;

  @override
  Stream<BleStatusReport> get statusReportStream => _statusReportController.stream;

  @override
  BleDeviceInfo? get connectedDevice => _connectedDevice;

  void _setConnectionState(BleConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
    _setConnectionState(BleConnectionState.scanning);

    // Cancel existing scan subscription
    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final maskDevices = results.where((r) {
        final advName = r.advertisementData.advName.trim().toUpperCase();
        final platName = r.device.platformName.trim().toUpperCase();
        final isMask = advName.contains('ALZMT') ||
            advName.contains('AIZMT') ||
            advName.contains('ZMT') ||
            advName.contains('AIMO') ||
            advName.contains('MASK') ||
            advName.contains('AIM') ||
            platName.contains('ALZMT') ||
            platName.contains('AIZMT') ||
            platName.contains('ZMT') ||
            platName.contains('AIMO') ||
            platName.contains('MASK') ||
            platName.contains('AIM');
        final hasService = r.advertisementData.serviceUuids
            .any((u) => u.toString().toUpperCase().contains('F760') || u.toString().toUpperCase().contains('F761'));
        return isMask || hasService;
      }).map((r) {
        final advName = r.advertisementData.advName.trim();
        final platName = r.device.platformName.trim();
        final name = advName.isNotEmpty
            ? advName
            : (platName.isNotEmpty ? platName : 'Alzmt Mask');

        return BleDeviceInfo(
          id: r.device.remoteId.str,
          name: name,
          rssi: r.rssi,
        );
      }).toList();

      // Sort by RSSI signal strength
      maskDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

      _scanResultsController.add(maskDevices);
    });

    try {
      // Ensure bluetooth adapter is checked
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        // Bluetooth is off or unauthorized
      }

      // Start scan without restrictive UUID filter so all broadcast packets are captured
      await FlutterBluePlus.startScan(
        timeout: timeout,
      );
    } catch (e) {
      _setConnectionState(BleConnectionState.disconnected);
    }

    FlutterBluePlus.isScanning.where((val) => !val).first.then((_) {
      if (_connectionState == BleConnectionState.scanning) {
        _setConnectionState(BleConnectionState.disconnected);
      }
    });
  }

  @override
  Future<void> stopScan() async {
    _scanSub?.cancel();
    await FlutterBluePlus.stopScan();
    if (_connectionState == BleConnectionState.scanning) {
      _setConnectionState(BleConnectionState.disconnected);
    }
  }

  @override
  Future<bool> connect(BleDeviceInfo deviceInfo) async {
    _setConnectionState(BleConnectionState.connecting);

    try {
      final device = BluetoothDevice.fromId(deviceInfo.id);
      _activeDevice = device;

      await device.connect(timeout: const Duration(seconds: 10));

      _deviceStateSub?.cancel();
      _deviceStateSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _cleanConnection();
        }
      });

      // Discover services
      final services = await device.discoverServices();
      for (final s in services) {
        if (s.uuid.toString().toUpperCase().contains('F760')) {
          for (final c in s.characteristics) {
            if (c.uuid.toString().toUpperCase().contains('F761')) {
              _writeCharacteristic = c;
              _notifyCharacteristic = c;
              break;
            }
          }
        }
      }

      // Fallback search if exact F760 was formatted differently
      if (_writeCharacteristic == null) {
        for (final s in services) {
          for (final c in s.characteristics) {
            if (c.properties.write || c.properties.writeWithoutResponse) {
              _writeCharacteristic = c;
            }
            if (c.properties.notify || c.properties.indicate) {
              _notifyCharacteristic = c;
            }
          }
        }
      }

      // Enable notifications
      if (_notifyCharacteristic != null) {
        await _notifyCharacteristic!.setNotifyValue(true);
        _notifySub?.cancel();
        _notifySub = _notifyCharacteristic!.onValueReceived.listen((data) {
          final report = BleProtocol.parseStatusPacket(Uint8List.fromList(data));
          if (report != null) {
            _statusReportController.add(report);
          }
        });
      }

      _connectedDevice = deviceInfo.copyWith(isConnected: true);
      _setConnectionState(BleConnectionState.connected);
      return true;
    } catch (e) {
      _cleanConnection();
      return false;
    }
  }

  void _cleanConnection() {
    _notifySub?.cancel();
    _deviceStateSub?.cancel();
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _connectedDevice = null;
    _activeDevice = null;
    _setConnectionState(BleConnectionState.disconnected);
  }

  @override
  Future<void> disconnect() async {
    _setConnectionState(BleConnectionState.disconnecting);
    try {
      await _activeDevice?.disconnect();
    } catch (_) {}
    _cleanConnection();
  }

  @override
  Future<bool> sendControlPacket(Uint8List packet) async {
    if (_connectionState != BleConnectionState.connected || _writeCharacteristic == null) {
      return false;
    }
    try {
      await _writeCharacteristic!.write(packet, withoutResponse: false);
      return true;
    } catch (e) {
      try {
        await _writeCharacteristic!.write(packet, withoutResponse: true);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _deviceStateSub?.cancel();
    _notifySub?.cancel();
    _connectionStateController.close();
    _scanResultsController.close();
    _statusReportController.close();
  }
}
