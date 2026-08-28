import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/ble/ble_device_info.dart';
import '../../../core/ble/ble_manager.dart';
import '../../../core/ble/ble_service_interface.dart';
import '../models/mask_mode.dart';

class SavedModePreset {
  final String id;
  final String name;
  final MaskModeType mode;
  final int gear;
  final DateTime createdAt;

  SavedModePreset({
    required this.id,
    required this.name,
    required this.mode,
    required this.gear,
    required this.createdAt,
  });
}

class MaskController extends ChangeNotifier {
  final BleManager _bleManager = BleManager.instance;

  StreamSubscription? _connSub;
  StreamSubscription? _statusSub;

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _activeDevice;

  MaskModeType _currentMode = MaskModeType.rejuvenating;
  int _currentGear = 3;
  bool _isPowerOn = false;
  int _batteryPercent = 80;
  int _remainingMinutes = 12;
  int _remainingSeconds = 0;
  SkinMetricData _skinMetrics = const SkinMetricData();

  Locale _currentLocale = const Locale('en');
  bool _hasAcknowledgedHighIntensity = false;

  final List<SavedModePreset> _savedPresets = [
    SavedModePreset(
      id: '1',
      name: 'Night Repair Ritual',
      mode: MaskModeType.rejuvenating,
      gear: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedModePreset(
      id: '2',
      name: 'Morning Firming & Glow',
      mode: MaskModeType.firming,
      gear: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  MaskController() {
    _initBleListeners();
  }

  // Getters
  BleConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == BleConnectionState.connected;
  BleDeviceInfo? get activeDevice => _activeDevice;
  MaskModeType get currentMode => _currentMode;
  int get currentGear => _currentGear;
  bool get isPowerOn => _isPowerOn;
  int get batteryPercent => _batteryPercent;
  int get remainingMinutes => _remainingMinutes;
  int get remainingSeconds => _remainingSeconds;
  SkinMetricData get skinMetrics => isConnected ? _skinMetrics : SkinMetricData.empty;
  Locale get currentLocale => _currentLocale;
  List<SavedModePreset> get savedPresets => List.unmodifiable(_savedPresets);
  bool get hasAcknowledgedHighIntensity => _hasAcknowledgedHighIntensity;

  String get formattedTime {
    if (!isConnected) return '--';
    final m = _remainingMinutes.toString().padLeft(2, '0');
    final s = _remainingSeconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get batteryLabel {
    if (!isConnected) return '--';
    return '$_batteryPercent%';
  }

  void _initBleListeners() {
    _connSub = _bleManager.connectionStateStream.listen((state) {
      _connectionState = state;
      _activeDevice = _bleManager.connectedDevice;
      if (state == BleConnectionState.connected) {
        _isPowerOn = true;
      } else if (state == BleConnectionState.disconnected) {
        _isPowerOn = false;
      }
      notifyListeners();
    });

    _statusSub = _bleManager.statusReportStream.listen((report) {
      _currentMode = MaskModeType.fromId(report.mode);
      _currentGear = report.gear;
      _isPowerOn = report.isOpen;
      _batteryPercent = report.battery;
      _remainingMinutes = report.workMinutes;
      _remainingSeconds = report.workSeconds;
      notifyListeners();
    });
  }

  void setLocale(Locale locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  void cycleLanguage() {
    if (_currentLocale.languageCode == 'en') {
      _currentLocale = const Locale('zh', 'CN');
    } else if (_currentLocale.languageCode == 'zh' &&
        (_currentLocale.countryCode == 'CN' || _currentLocale.countryCode == null)) {
      _currentLocale = const Locale('zh', 'TW');
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setMode(MaskModeType mode) async {
    _currentMode = mode;
    notifyListeners();
    if (isConnected) {
      await _bleManager.sendControl(
        mode: mode.id,
        gear: _currentGear,
        isOpen: _isPowerOn,
      );
    }
  }

  Future<void> setGear(int gear) async {
    final clampedGear = gear.clamp(1, 16);
    _currentGear = clampedGear;
    notifyListeners();
    if (isConnected) {
      await _bleManager.sendControl(
        mode: _currentMode.id,
        gear: clampedGear,
        isOpen: _isPowerOn,
      );
    }
  }

  void acknowledgeHighIntensity() {
    _hasAcknowledgedHighIntensity = true;
    notifyListeners();
  }

  Future<void> togglePower() async {
    if (!isConnected) return;
    _isPowerOn = !_isPowerOn;
    notifyListeners();
    await _bleManager.sendControl(
      mode: _currentMode.id,
      gear: _currentGear,
      isOpen: _isPowerOn,
    );
  }

  Future<bool> connect(BleDeviceInfo device) async {
    final success = await _bleManager.connect(device);
    return success;
  }

  Future<void> disconnect() async {
    await _bleManager.disconnect();
  }

  void saveCurrentPreset(String name) {
    final newPreset = SavedModePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.isNotEmpty ? name : 'Custom Preset ${_savedPresets.length + 1}',
      mode: _currentMode,
      gear: _currentGear,
      createdAt: DateTime.now(),
    );
    _savedPresets.insert(0, newPreset);
    notifyListeners();
  }

  void applyPreset(SavedModePreset preset) {
    setMode(preset.mode);
    setGear(preset.gear);
  }

  void deletePreset(String id) {
    _savedPresets.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}
