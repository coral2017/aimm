import 'dart:async';
import 'dart:math';
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
  Timer? _countdownTimer;
  Timer? _heartbeatWatchdogTimer;
  DateTime _lastHeartbeatTime = DateTime.now();

  final StreamController<String> _globalAlertController = StreamController<String>.broadcast();
  Stream<String> get globalAlertStream => _globalAlertController.stream;

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleDeviceInfo? _activeDevice;

  MaskModeType _currentMode = MaskModeType.rejuvenating;
  int _currentGear = 1; // Default initial gear is 1
  bool _isPowerOn = false; // Default initial state is Stopped
  int _batteryPercent = 80;

  // 12 Minutes Treatment Timer (720 seconds total)
  static const int totalTreatmentSeconds = 12 * 60;
  int _remainingSecondsTotal = totalTreatmentSeconds;

  final SkinMetricData _skinMetrics = const SkinMetricData();
  Locale _currentLocale = const Locale('en');
  bool _hasAcknowledgedHighIntensity = false;

  // Combination Mode State
  bool _isCombinationActive = false;
  List<MaskModeType> _combinationSequence = [];
  int _combinationCurrentStage = 0;

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
    _startHeartbeatWatchdog();
  }

  // Getters
  BleConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == BleConnectionState.connected;
  BleDeviceInfo? get activeDevice => _activeDevice;
  MaskModeType get currentMode => _currentMode;
  int get currentGear => _currentGear;
  bool get isPowerOn => _isPowerOn;
  bool get isRunning => _isPowerOn && isConnected;
  bool get canAdjustGear => isRunning;
  int get batteryPercent => _batteryPercent;
  int get remainingSecondsTotal => _remainingSecondsTotal;
  int get remainingMinutes => _remainingSecondsTotal ~/ 60;
  int get remainingSeconds => _remainingSecondsTotal % 60;
  SkinMetricData get skinMetrics => isConnected ? _skinMetrics : SkinMetricData.empty;
  Locale get currentLocale => _currentLocale;
  List<SavedModePreset> get savedPresets => List.unmodifiable(_savedPresets);
  bool get hasAcknowledgedHighIntensity => _hasAcknowledgedHighIntensity;
  bool get isCombinationActive => _isCombinationActive;
  int get combinationCurrentStage => _combinationCurrentStage;

  String get formattedTime {
    if (!isConnected) return '--';
    final m = remainingMinutes.toString().padLeft(2, '0');
    final s = remainingSeconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get batteryLabel {
    if (!isConnected) return '--';
    return '$_batteryPercent%';
  }

  void _initBleListeners() {
    _connSub = _bleManager.connectionStateStream.listen((state) {
      final oldState = _connectionState;
      _connectionState = state;
      _activeDevice = _bleManager.connectedDevice;

      if (state == BleConnectionState.connected) {
        _lastHeartbeatTime = DateTime.now();
        // Reset to clean initial state on connection: Gear 1, Stopped, 12:00
        _currentGear = 1;
        _isPowerOn = false;
        _remainingSecondsTotal = totalTreatmentSeconds;
        _isCombinationActive = false;
        _stopCountdown();
      } else if (state == BleConnectionState.disconnected) {
        final wasRunningOrConnected = oldState == BleConnectionState.connected;
        _isPowerOn = false;
        _isCombinationActive = false;
        _stopCountdown();

        // If connection dropped unexpectedly, alert user
        if (wasRunningOrConnected) {
          _globalAlertController.add('deviceDisconnectedAlert');
        }
      }
      notifyListeners();
    });

    _statusSub = _bleManager.statusReportStream.listen((report) {
      _lastHeartbeatTime = DateTime.now();
      final oldBattery = _batteryPercent;
      _batteryPercent = report.battery;

      // Low battery warning threshold (<= 15%)
      if (_batteryPercent <= 15 && oldBattery > 15) {
        _globalAlertController.add('lowBatteryAlert');
      }

      notifyListeners();
    });
  }

  void _startHeartbeatWatchdog() {
    _heartbeatWatchdogTimer?.cancel();
    _heartbeatWatchdogTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (isConnected && isRunning) {
        final timeSinceLastReport = DateTime.now().difference(_lastHeartbeatTime);
        // If no status packet received for more than 7 seconds while running
        if (timeSinceLastReport.inSeconds > 7) {
          // Device might have dropped offline / out of battery
          _globalAlertController.add('heartbeatTimeoutAlert');
        }
      }
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

  /// Switch mode: Resets running state to Stopped, gear to 1, and pauses timer at current timestamp
  Future<void> setMode(MaskModeType mode) async {
    _isCombinationActive = false;
    _currentMode = mode;
    _isPowerOn = false; // Stopped on mode switch
    _currentGear = 1; // Reset to gear 1
    _stopCountdown(); // Pause timer at current remaining time
    notifyListeners();

    if (isConnected) {
      await _bleManager.sendControl(
        mode: mode.id,
        gear: 1,
        isOpen: false,
      );
    }
  }

  /// Adjust gear: Only permitted when device is running
  Future<bool> setGear(int gear) async {
    if (!isRunning) {
      return false; // Intercept: Must start before adjusting gear
    }

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
    return true;
  }

  void acknowledgeHighIntensity() {
    _hasAcknowledgedHighIntensity = true;
    notifyListeners();
  }

  /// Toggle Start / Pause
  Future<void> togglePower() async {
    if (!isConnected) return;

    if (_isPowerOn) {
      // Transition from Running -> Paused
      _isPowerOn = false;
      _stopCountdown();
    } else {
      // Transition from Paused/Stopped -> Running
      if (_remainingSecondsTotal <= 0) {
        _remainingSecondsTotal = totalTreatmentSeconds;
      }
      _isPowerOn = true;
      _startCountdown();
    }

    notifyListeners();

    await _bleManager.sendControl(
      mode: _currentMode.id,
      gear: _currentGear,
      isOpen: _isPowerOn,
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPowerOn || !isConnected) {
        timer.cancel();
        return;
      }

      if (_remainingSecondsTotal > 0) {
        _remainingSecondsTotal--;

        // If in combination mode, check if we need to advance to next 2-minute stage
        if (_isCombinationActive && _combinationSequence.isNotEmpty) {
          final elapsedSeconds = totalTreatmentSeconds - _remainingSecondsTotal;
          final targetStage = (elapsedSeconds ~/ 120).clamp(0, _combinationSequence.length - 1);
          if (targetStage != _combinationCurrentStage) {
            _combinationCurrentStage = targetStage;
            _currentMode = _combinationSequence[targetStage];
            // Send updated mode command to BLE mask
            _bleManager.sendControl(
              mode: _currentMode.id,
              gear: _currentGear,
              isOpen: true,
            );
          }
        }
        notifyListeners();
      } else {
        // Timer completed (12 minutes reached)
        _isPowerOn = false;
        _isCombinationActive = false;
        _stopCountdown();
        _remainingSecondsTotal = totalTreatmentSeconds; // Reset to 12:00 for next session
        _globalAlertController.add('treatmentCompleteAlert');
        notifyListeners();

        _bleManager.sendControl(
          mode: _currentMode.id,
          gear: _currentGear,
          isOpen: false,
        );
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Start Combination Mode (6 modes x 2 minutes = 12 minutes total)
  Future<void> startCombinationMode({bool isRandom = false}) async {
    final allModes = List<MaskModeType>.from(MaskModeType.values);
    if (isRandom) {
      allModes.shuffle(Random());
    }

    _combinationSequence = allModes;
    _combinationCurrentStage = 0;
    _isCombinationActive = true;
    _currentMode = _combinationSequence[0];
    _currentGear = 1;
    _remainingSecondsTotal = totalTreatmentSeconds;
    _isPowerOn = true;

    notifyListeners();
    _startCountdown();

    if (isConnected) {
      await _bleManager.sendControl(
        mode: _currentMode.id,
        gear: 1,
        isOpen: true,
      );
    }
  }

  Future<bool> connect(BleDeviceInfo device) async {
    final success = await _bleManager.connect(device);
    return success;
  }

  /// Unbind / Disconnect from current device
  Future<void> unbindCurrentDevice() async {
    _isPowerOn = false;
    _isCombinationActive = false;
    _stopCountdown();
    await _bleManager.disconnect();
    _activeDevice = null;
    _connectionState = BleConnectionState.disconnected;
    _remainingSecondsTotal = totalTreatmentSeconds;
    _currentGear = 1;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await unbindCurrentDevice();
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
    _currentGear = preset.gear;
    notifyListeners();
  }

  void deletePreset(String id) {
    _savedPresets.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _statusSub?.cancel();
    _countdownTimer?.cancel();
    _heartbeatWatchdogTimer?.cancel();
    _globalAlertController.close();
    super.dispose();
  }
}
