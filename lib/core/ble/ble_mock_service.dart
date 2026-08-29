import 'dart:async';
import 'dart:typed_data';
import 'ble_device_info.dart';
import 'ble_protocol.dart';
import 'ble_service_interface.dart';

/// Simulated Bluetooth Low Energy service for testing, development, and non-mobile targets
class BleMockService implements IBleService {
  final _connectionStateController = StreamController<BleConnectionState>.broadcast();
  final _scanResultsController = StreamController<List<BleDeviceInfo>>.broadcast();
  final _statusReportController = StreamController<BleStatusReport>.broadcast();

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _connectedDevice;
  Timer? _scanTimer;
  Timer? _heartbeatTimer;

  // Simulated MCU state
  int _currentMode = 0; // Rejuvenating (0)
  int _currentGear = 1; // Gear 1 (Initial)
  bool _isPowerOn = false; // Stopped (Initial)
  final int _batteryPercent = 80;
  int _workMinutes = 12;
  int _workSeconds = 0;

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
  Future<void> startScan({Duration timeout = const Duration(seconds: 4)}) async {
    _setConnectionState(BleConnectionState.scanning);

    final mockDevices = [
      const BleDeviceInfo(
        id: 'EF0A92E5-A99C-EC12-BADF-9E7ADE45FC29',
        name: 'AIMO Mask V2',
        rssi: -52,
      ),
      const BleDeviceInfo(
        id: 'B48C19D2-F81A-492B-AA70-38829F1A2C8D',
        name: 'AIMO Intelligent Hub',
        rssi: -71,
      ),
    ];

    // Simulate discovering devices after 800ms
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 800), () {
      _scanResultsController.add(mockDevices);
    });

    Timer(timeout, () {
      if (_connectionState == BleConnectionState.scanning) {
        _setConnectionState(BleConnectionState.disconnected);
      }
    });
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    if (_connectionState == BleConnectionState.scanning) {
      _setConnectionState(BleConnectionState.disconnected);
    }
  }

  @override
  Future<bool> connect(BleDeviceInfo device) async {
    _setConnectionState(BleConnectionState.connecting);
    await Future.delayed(const Duration(milliseconds: 1200));

    _connectedDevice = device.copyWith(isConnected: true);
    _setConnectionState(BleConnectionState.connected);
    _startHeartbeat();
    return true;
  }

  @override
  Future<void> disconnect() async {
    _setConnectionState(BleConnectionState.disconnecting);
    _stopHeartbeat();
    await Future.delayed(const Duration(milliseconds: 300));
    _connectedDevice = null;
    _setConnectionState(BleConnectionState.disconnected);
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_connectionState != BleConnectionState.connected) {
        timer.cancel();
        return;
      }

      if (_isPowerOn) {
        if (_workSeconds > 0) {
          _workSeconds--;
        } else if (_workMinutes > 0) {
          _workMinutes--;
          _workSeconds = 59;
        } else {
          // Timer finished
          _isPowerOn = false;
        }
      }

      final report = BleStatusReport(
        mode: _currentMode,
        gear: _currentGear,
        isOpen: _isPowerOn,
        battery: _batteryPercent,
        workMinutes: _workMinutes,
        workSeconds: _workSeconds,
      );

      _statusReportController.add(report);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  Future<bool> sendControlPacket(Uint8List packet) async {
    if (_connectionState != BleConnectionState.connected) {
      return false;
    }

    // Parse packet directly
    if (packet.length == BleProtocol.packetLength && packet[5] == BleProtocol.funcCodeControl) {
      _currentMode = packet[6];
      _currentGear = packet[7];
      _isPowerOn = packet[8] == 0x01;

      // If turning on and timer was zero, reset to 12 minutes
      if (_isPowerOn && _workMinutes == 0 && _workSeconds == 0) {
        _workMinutes = 12;
        _workSeconds = 0;
      }

      // Immediately broadcast status update
      final report = BleStatusReport(
        mode: _currentMode,
        gear: _currentGear,
        isOpen: _isPowerOn,
        battery: _batteryPercent,
        workMinutes: _workMinutes,
        workSeconds: _workSeconds,
      );
      _statusReportController.add(report);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _stopHeartbeat();
    _connectionStateController.close();
    _scanResultsController.close();
    _statusReportController.close();
  }
}
