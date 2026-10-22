import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../storage/device_storage_service.dart';
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

    final boundDevice = await DeviceStorageService.instance.getBoundDevice();
    final boundId = boundDevice?.id;

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
        final isBoundDevice = boundId != null && r.device.remoteId.str == boundId;
        return isMask || hasService || isBoundDevice;
      }).map((r) {
        final advName = r.advertisementData.advName.trim();
        final platName = r.device.platformName.trim();
        final isBoundDevice = boundId != null && r.device.remoteId.str == boundId;
        final name = advName.isNotEmpty
            ? advName
            : (platName.isNotEmpty
                ? platName
                : (isBoundDevice ? (boundDevice?.name ?? 'Alzmt Mask') : 'Alzmt Mask'));

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

      debugPrint('🔗 [BLE 连接] 正在发起 GATT 连接: ${deviceInfo.name} (${deviceInfo.id})');
      await device.connect(timeout: const Duration(seconds: 10));
      debugPrint('🔗 [BLE 连接] 底层 GATT 连接成功，正在发现服务...');

      _deviceStateSub?.cancel();
      _deviceStateSub = device.connectionState.listen((state) {
        debugPrint('🔗 [BLE 状态变化] Gatt State -> $state');
        if (state == BluetoothConnectionState.disconnected) {
          _cleanConnection();
        }
      });

      // Discover services
      final services = await device.discoverServices();
      for (final s in services) {
        debugPrint('   [GATT 服务] ${s.uuid}');
        if (s.uuid.toString().toUpperCase().contains('F760')) {
          for (final c in s.characteristics) {
            debugPrint('     └─ [GATT 特征值] ${c.uuid} (write:${c.properties.write}, writeNoResp:${c.properties.writeWithoutResponse}, notify:${c.properties.notify})');
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
        debugPrint('   ⚠️ 未精确匹配到 F760/F761，正在通过属性特征兜底匹配...');
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

      debugPrint('🔗 [BLE 匹配完成] 写特征: ${_writeCharacteristic?.uuid}, 监听特征: ${_notifyCharacteristic?.uuid}');

      // Enable notifications
      if (_notifyCharacteristic != null) {
        await _notifyCharacteristic!.setNotifyValue(true);
        debugPrint('🔔 [BLE 监听] 已成功开启特征值 Notify 监听: ${_notifyCharacteristic!.uuid}');
        _notifySub?.cancel();
        _notifySub = _notifyCharacteristic!.onValueReceived.listen((data) {
          final hexStr = data.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
          debugPrint('📥 [BLE RX 收到从机报文] ($hexStr) [字节数=${data.length}]');

          final bytes = Uint8List.fromList(data);
          final report = BleProtocol.parseStatusPacket(bytes);
          if (report != null) {
            debugPrint('   └─✅ [从机状态] 模式=${report.mode}, 档位=${report.gear}, 运行开关=${report.isOpen ? "【开 ON】" : "【关 OFF】"}, 电量=${report.battery}%, 时间=${report.workMinutes}分${report.workSeconds}秒');
            _statusReportController.add(report);
          } else {
            // Diagnose parsing failure
            String reason = '';
            if (data.length != 20) {
              reason = '长度非20字节 (实际${data.length})';
            } else if (data[0] != 0x45 || data[1] != 0xA2) {
              reason = '帧头不符合45 A2';
            } else if (data[18] != 0x2C || data[19] != 0xFF) {
              reason = '帧尾不符合2C FF';
            } else if (data[5] != 0xA4 && data[5] != 0xA1) {
              reason = '功能码非A4/A1 (0x${data[5].toRadixString(16)})';
            } else {
              reason = '校验不通过';
            }
            debugPrint('   └─⚠️ [从机报文未解析] $reason');
          }
        });
      }

      _connectedDevice = deviceInfo.copyWith(isConnected: true);
      _setConnectionState(BleConnectionState.connected);
      debugPrint('🎉 [BLE 连接成功] 设备已绑定并就绪: ${deviceInfo.name}');
      return true;
    } catch (e, stack) {
      debugPrint('❌ [BLE 连接异常] 连接失败: $e\n$stack');
      _cleanConnection();
      return false;
    }
  }

  void _cleanConnection() {
    debugPrint('🔌 [BLE 断开] 清理连接状态与资源');
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
    debugPrint('🔌 [BLE 断开] 主动发起断开连接');
    _setConnectionState(BleConnectionState.disconnecting);
    try {
      await _activeDevice?.disconnect();
    } catch (_) {}
    _cleanConnection();
  }

  @override
  Future<bool> sendControlPacket(Uint8List packet) async {
    final hexStr = packet.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
    debugPrint('📤 [BLE TX 主机发送指令] ($hexStr) [字节数=${packet.length}]');

    if (_connectionState != BleConnectionState.connected || _writeCharacteristic == null) {
      debugPrint('   └─❌ 发送失败: 设备未连接或写特征值未就绪 (State: $_connectionState, Char: ${_writeCharacteristic?.uuid})');
      return false;
    }
    try {
      await _writeCharacteristic!.write(packet, withoutResponse: true);
      debugPrint('   └─✅ 发送成功 (模式: WriteWithoutResponse / 0x52)');
      return true;
    } catch (e) {
      debugPrint('   └─⚠️ WriteWithoutResponse 失败 ($e)，正在尝试 WithResponse 模式重发...');
      try {
        await _writeCharacteristic!.write(packet, withoutResponse: false);
        debugPrint('   └─✅ 发送成功 (模式: WriteWithResponse)');
        return true;
      } catch (e2) {
        debugPrint('   └─❌ 两次写入尝试均失败: $e2');
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
