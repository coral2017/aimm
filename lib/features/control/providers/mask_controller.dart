import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/ble/ble_device_info.dart';
import '../../../core/ble/ble_manager.dart';
import '../../../core/ble/ble_protocol.dart';
import '../../../core/ble/ble_service_interface.dart';
import '../../../core/storage/device_storage_service.dart';
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
  BleDeviceInfo? _boundDevice;
  bool _isAutoReconnecting = false;
  Timer? _autoReconnectTimer;
  int _autoReconnectAttemptCount = 0;
  StreamSubscription? _scanResultsSub;

  static const int maxGear = 10;
  DateTime? _lastStartRequestTime;
  DateTime? _lastPauseRequestTime;

  MaskModeType? _selectedMode; // Nullable: unselected upon connection
  int _currentGear = 1; // Default initial gear is 1 (Range: 1 ~ 10)
  bool _isPowerOn = false; // Default initial state is Stopped
  int _batteryPercent = 80;

  // 12 Minutes Treatment Timer (720 seconds total)
  static const int totalTreatmentSeconds = 12 * 60;
  int _remainingSecondsTotal = totalTreatmentSeconds;

  SkinMetricData _skinMetrics = SkinMetricData.empty;
  Locale _currentLocale = const Locale('en');
  bool _hasAcknowledgedHighIntensity = false;

  // Combination Mode State
  bool _isCombinationActive = false;
  List<MaskModeType> _combinationSequence = List<MaskModeType>.from(MaskModeType.values);
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
    _loadBoundDeviceAndAutoConnect();
  }

  // Getters
  BleConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == BleConnectionState.connected;
  BleDeviceInfo? get activeDevice => _activeDevice;
  BleDeviceInfo? get boundDevice => _boundDevice;
  bool get isBound => _boundDevice != null;
  bool get isAutoReconnecting => _isAutoReconnecting;
  MaskModeType? get selectedMode => _selectedMode;

  /// Returns currently selected mode, or underlying stage mode if in combination, or fallback
  MaskModeType get currentMode => _selectedMode ?? activeUnderlyingMode;

  /// Returns the underlying physical mode for BLE transmission (combination or single mode)
  MaskModeType get activeUnderlyingMode {
    if (_isCombinationActive) {
      final elapsed = totalTreatmentSeconds - _remainingSecondsTotal;
      final stage = (elapsed ~/ 120).clamp(0, 5);
      return _combinationSequence.isNotEmpty
          ? _combinationSequence[stage]
          : MaskModeType.values[stage];
    }
    return _selectedMode ?? MaskModeType.rejuvenating;
  }

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
        stopAutoReconnect();
        _lastHeartbeatTime = DateTime.now();
        // Reset to initial clean state on connection: No mode selected, Gear 1, Stopped, 12:00
        _selectedMode = null;
        _isCombinationActive = false;
        _currentGear = 1;
        _isPowerOn = false;
        _remainingSecondsTotal = totalTreatmentSeconds;
        _stopCountdown();

        if (_activeDevice != null) {
          _boundDevice = _activeDevice;
          DeviceStorageService.instance.saveBoundDevice(_activeDevice!);
        }
      } else if (state == BleConnectionState.disconnected) {
        final wasRunningOrConnected = oldState == BleConnectionState.connected;
        _isPowerOn = false;
        _isCombinationActive = false;
        _stopCountdown();

        // If connection dropped unexpectedly, alert user
        if (wasRunningOrConnected) {
          _globalAlertController.add('deviceDisconnectedAlert');
        }

        // If still bound (user did not explicitly unbind), trigger auto-reconnect
        if (_boundDevice != null) {
          triggerAutoReconnect();
        }
      }
      notifyListeners();
    });

    _scanResultsSub = _bleManager.scanResultsStream.listen((devices) {
      if (_isAutoReconnecting && _boundDevice != null && !isConnected) {
        for (final device in devices) {
          if (device.id == _boundDevice!.id) {
            stopAutoReconnect();
            connect(device);
            break;
          }
        }
      }
    });

    _statusSub = _bleManager.statusReportStream.listen(_onStatusReport);
  }

  @visibleForTesting
  void handleStatusReportForTesting(BleStatusReport report) => _onStatusReport(report);

  void _onStatusReport(BleStatusReport report) {
    _lastHeartbeatTime = DateTime.now();
    final oldBattery = _batteryPercent;
    _batteryPercent = report.battery;

    // Low battery warning threshold (<= 15%)
    if (_batteryPercent <= 15 && oldBattery > 15) {
      _globalAlertController.add('lowBatteryAlert');
    }

    // 【核心特性：无缝续住时间与运行状态（与小程序对齐）】
    // 如果从机当前正在运行 (report.isOpen == true)：
    if (report.isOpen) {
      final mcuRemainingSeconds = report.workMinutes * 60 + report.workSeconds;
      final elapsedSincePause = _lastPauseRequestTime != null
          ? DateTime.now().difference(_lastPauseRequestTime!).inMilliseconds
          : 9999;

      // 如果 App 本地未启动，且并非刚刚由 App 主动下发暂停（避免飞行中的旧报文误唤醒），直接同步接续从机的运行状态与时间
      if (!_isPowerOn && elapsedSincePause > 1500) {
        debugPrint('🔄 [从机状态接续] 从机正在运行中，同步接续运行状态与时间: ${report.workMinutes}分${report.workSeconds}秒 (模式: ${report.mode}, 档位: ${report.gear})');
        _isPowerOn = true;
        _remainingSecondsTotal = mcuRemainingSeconds > 0 ? mcuRemainingSeconds : totalTreatmentSeconds;

        // 若此前未选模式且未进入综合模式，尝试根据从机模式值恢复
        if (_selectedMode == null && !_isCombinationActive) {
          _selectedMode = MaskModeType.fromFirmwareValue(report.mode);
          _currentGear = _selectedMode!.getUiGearFromBle(report.gear);
        }
        if (_skinMetrics.isEmpty) {
          _skinMetrics = SkinMetricData.initialBaseline;
        }
        _startCountdown();
      } else {
        // 如果已经在运行中，与下位机时间偏差超过 3 秒平滑对齐（下位机与 App 保持一致的全局 12 分钟倒计时）
        if ((_remainingSecondsTotal - mcuRemainingSeconds).abs() > 3 && mcuRemainingSeconds > 0) {
          _remainingSecondsTotal = mcuRemainingSeconds;
        }
      }
    } else {
      // 未接触皮肤/缺水保护及从机状态回弹机制：
      if (_isPowerOn) {
        final elapsedSinceStart = _lastStartRequestTime != null
            ? DateTime.now().difference(_lastStartRequestTime!).inMilliseconds
            : 9999;

        if (elapsedSinceStart > 1200 && !report.isOpen) {
          debugPrint('⚠️ [MCU 离体保护回弹] 从机处于关闭状态 (packet[8] 开关: OFF)，可能未贴合皮肤或缺乏水分导电，自动回弹停止');
          _isPowerOn = false;
          _stopCountdown();
          _globalAlertController.add('skinContactDetached');
        }
      }
    }

    notifyListeners();
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

  /// Switch mode:
  /// - If running: Keep running without pause, reset UI gear to 1, send new mode with gear 1 (isOpen: true)
  /// - If stopped: Keep stopped, reset UI gear to 1, send new mode with gear 1 (isOpen: false)
  Future<void> setMode(MaskModeType mode) async {
    debugPrint('👉 [App UI 操作] 切换模式 -> ${mode.name} (固件值: 0x${mode.firmwareValue.toRadixString(16)}, 起始档位: ${mode.startGear}, 运行中: $_isPowerOn)');
    _isCombinationActive = false;
    _selectedMode = mode;
    _currentGear = 1; // Always reset UI gear to 1 on mode switch

    // Do NOT stop countdown or pause power if currently running!
    notifyListeners();

    if (isConnected) {
      await _bleManager.sendControl(
        mode: mode.firmwareValue,
        gear: mode.startGear,
        isOpen: _isPowerOn, // Seamlessly keep current power state!
      );
    }
  }

  /// Switch to Combination Mode:
  /// - Has its own independent active state (selectedMode becomes null)
  /// - Seamlessly fits into the 12-minute treatment timeline
  /// - If running: Keep running without pause, reset UI gear to 1, send underlying stage mode with gear 1
  /// - If stopped: Keep stopped, reset UI gear to 1
  Future<void> switchToCombinationMode() async {
    _isCombinationActive = true;
    _selectedMode = null; // Unselect single modes
    _currentGear = 1; // Reset UI gear to 1

    if (_combinationSequence.isEmpty) {
      _combinationSequence = List<MaskModeType>.from(MaskModeType.values);
    }

    final elapsed = totalTreatmentSeconds - _remainingSecondsTotal;
    _combinationCurrentStage = (elapsed ~/ 120).clamp(0, 5);
    final targetMode = _combinationSequence[_combinationCurrentStage];

    debugPrint('👉 [App UI 操作] 切换到综合模式 (阶段: ${_combinationCurrentStage + 1}/6, 底层模式: ${targetMode.name}, 运行中: $_isPowerOn, 剩余时间: $_remainingSecondsTotal秒)');

    notifyListeners();

    if (isConnected) {
      await _bleManager.sendControl(
        mode: targetMode.firmwareValue,
        gear: targetMode.getBleGear(1),
        isOpen: _isPowerOn, // Seamlessly keep current power state!
      );
    }
  }

  /// Adjust gear: Only permitted when device is running
  Future<bool> setGear(int gear) async {
    if (!isRunning) {
      debugPrint('👉 [App UI 操作] 试图调节档位，但当前未处于运行状态被拦截 (gear: $gear)');
      return false; // Intercept: Must start before adjusting gear
    }

    final clampedGear = gear.clamp(1, maxGear);
    final underlying = activeUnderlyingMode;
    final targetBleGear = underlying.getBleGear(clampedGear);
    debugPrint('👉 [App UI 操作] 调节档位 -> $clampedGear 档 (模式: ${underlying.name}, 下发BLE通信档位: $targetBleGear, 运行中: $_isPowerOn)');
    _currentGear = clampedGear;
    notifyListeners();

    if (isConnected) {
      await _bleManager.sendControl(
        mode: underlying.firmwareValue,
        gear: targetBleGear,
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

    // Safety guard: Must have a mode selected or combination mode active
    if (_selectedMode == null && !_isCombinationActive) {
      debugPrint('👉 [App UI 操作] 点击开始，但未选择任何模式或综合模式，予以拦截');
      _globalAlertController.add('pleaseSelectMode');
      return;
    }

    final targetPower = !_isPowerOn;

    if (_isPowerOn) {
      // Transition from Running -> Paused
      _isPowerOn = false;
      _lastPauseRequestTime = DateTime.now();
      _stopCountdown();
    } else {
      // Transition from Paused/Stopped -> Running
      _lastPauseRequestTime = null;
      // Safety rule: Always reset gear to 1 when restarting to prevent sudden high-intensity surge!
      _currentGear = 1;

      if (_remainingSecondsTotal <= 0) {
        _remainingSecondsTotal = totalTreatmentSeconds;
        _skinMetrics = SkinMetricData.initialBaseline;
      } else if (_skinMetrics.isEmpty) {
        _skinMetrics = SkinMetricData.initialBaseline;
      }
      _isPowerOn = true;
      _lastStartRequestTime = DateTime.now();
      _startCountdown();
    }

    final underlying = activeUnderlyingMode;
    final targetBleGear = underlying.getBleGear(_currentGear);
    debugPrint('👉 [App UI 操作] 点击【${targetPower ? "开始运行" : "暂停运行"}】 (模式: ${underlying.name}[FW:0x${underlying.firmwareValue.toRadixString(16)}], UI档位: $_currentGear -> BLE通信档位: $targetBleGear)');

    notifyListeners();

    await _bleManager.sendControl(
      mode: underlying.firmwareValue,
      gear: targetBleGear,
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

        // Calculate dynamic skin metrics filling per second (Tick = 1s)
        final elapsedSeconds = totalTreatmentSeconds - _remainingSecondsTotal;
        final phaseFactor = SkinMetricConfig.getPhaseFactor(elapsedSeconds);
        final gearFactor = SkinMetricConfig.getGearFactor(_currentGear);
        const vBase = SkinMetricConfig.vBase;

        final weights = _isCombinationActive
            ? SkinMetricConfig.combinationWeights
            : (SkinMetricConfig.modeWeights[activeUnderlyingMode] ?? SkinMetricConfig.combinationWeights);

        final deltaDelicacy = vBase * (weights[SkinMetricType.delicacy] ?? 1.0) * phaseFactor * gearFactor;
        final deltaHydration = vBase * (weights[SkinMetricType.hydration] ?? 1.0) * phaseFactor * gearFactor;
        final deltaYouthfulness = vBase * (weights[SkinMetricType.youthfulness] ?? 1.0) * phaseFactor * gearFactor;
        final deltaClarity = vBase * (weights[SkinMetricType.clarity] ?? 1.0) * phaseFactor * gearFactor;

        _skinMetrics = _skinMetrics.copyWith(
          smoothness: (_skinMetrics.smoothness + deltaDelicacy).clamp(0.0, 0.95),
          hydration: (_skinMetrics.hydration + deltaHydration).clamp(0.0, 0.95),
          youthfulness: (_skinMetrics.youthfulness + deltaYouthfulness).clamp(0.0, 0.95),
          skinTone: (_skinMetrics.skinTone + deltaClarity).clamp(0.0, 0.95),
        );

        // If in combination mode, check if we need to advance to next 2-minute stage
        if (_isCombinationActive && _combinationSequence.isNotEmpty) {
          final targetStage = (elapsedSeconds ~/ 120).clamp(0, _combinationSequence.length - 1);
          if (targetStage != _combinationCurrentStage) {
            _combinationCurrentStage = targetStage;
            final stageMode = _combinationSequence[targetStage];
            // Send updated mode command to BLE mask, maintaining current gear
            _bleManager.sendControl(
              mode: stageMode.firmwareValue,
              gear: stageMode.getBleGear(_currentGear),
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

        final underlying = activeUnderlyingMode;
        _bleManager.sendControl(
          mode: underlying.firmwareValue,
          gear: underlying.getBleGear(_currentGear),
          isOpen: false,
        );
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Start Combination Mode (Delegates to switchToCombinationMode and starts power if needed)
  Future<void> startCombinationMode({bool isRandom = false}) async {
    final allModes = List<MaskModeType>.from(MaskModeType.values);
    if (isRandom) {
      allModes.shuffle(Random());
    }
    _combinationSequence = allModes;
    await switchToCombinationMode();
    if (!_isPowerOn) {
      await togglePower();
    }
  }

  Future<void> _loadBoundDeviceAndAutoConnect() async {
    try {
      final saved = await DeviceStorageService.instance.getBoundDevice();
      if (saved != null) {
        _boundDevice = saved;
        notifyListeners();
        triggerAutoReconnect();
      }
    } catch (_) {}
  }

  /// Trigger auto reconnect scan loop
  void triggerAutoReconnect() {
    if (!isBound || isConnected) return;

    _isAutoReconnecting = true;
    _autoReconnectAttemptCount = 0;
    notifyListeners();

    _performAutoReconnectCycle();
  }

  /// Stop auto reconnect loop
  void stopAutoReconnect() {
    _isAutoReconnecting = false;
    _autoReconnectTimer?.cancel();
    _autoReconnectTimer = null;
    _bleManager.stopScan();
  }

  void _performAutoReconnectCycle() {
    _autoReconnectTimer?.cancel();
    if (!isBound || isConnected || !_isAutoReconnecting) {
      _isAutoReconnecting = false;
      return;
    }

    _autoReconnectAttemptCount++;
    // Scan for 5 seconds
    _bleManager.startScan(timeout: const Duration(seconds: 5));

    // Dynamic backoff strategy:
    // First 6 attempts (~48s): scan every 8s (5s scan + 3s pause)
    // Subsequent attempts: scan every 18s (5s scan + 13s pause) to conserve phone battery
    final delaySeconds = _autoReconnectAttemptCount <= 6 ? 8 : 18;

    _autoReconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (isBound && !isConnected && _isAutoReconnecting) {
        _performAutoReconnectCycle();
      }
    });
  }

  /// Called when app resumes from background
  void onAppResumed() {
    if (isBound && !isConnected) {
      triggerAutoReconnect();
    }
  }

  Future<bool> connect(BleDeviceInfo device) async {
    debugPrint('👉 [App UI 操作] 请求连接设备 -> ${device.name} (${device.id})');
    stopAutoReconnect();
    final success = await _bleManager.connect(device);
    if (success) {
      _boundDevice = device;
      await DeviceStorageService.instance.saveBoundDevice(device);
      notifyListeners();
    }
    return success;
  }

  /// Unbind / Disconnect from current device
  Future<void> unbindCurrentDevice() async {
    debugPrint('👉 [App UI 操作] 解绑/断开设备');
    stopAutoReconnect();
    _isPowerOn = false;
    _isCombinationActive = false;
    _selectedMode = null;
    _stopCountdown();

    await DeviceStorageService.instance.clearBoundDevice();
    _boundDevice = null;
    _activeDevice = null;
    _connectionState = BleConnectionState.disconnected;

    await _bleManager.disconnect();
    stopAutoReconnect();
    _boundDevice = null;
    _isAutoReconnecting = false;
    _remainingSecondsTotal = totalTreatmentSeconds;
    _currentGear = 1;
    _skinMetrics = SkinMetricData.empty;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await unbindCurrentDevice();
  }

  void saveCurrentPreset(String name) {
    final newPreset = SavedModePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.isNotEmpty ? name : 'Custom Preset ${_savedPresets.length + 1}',
      mode: currentMode,
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
    stopAutoReconnect();
    _scanResultsSub?.cancel();
    _connSub?.cancel();
    _statusSub?.cancel();
    _countdownTimer?.cancel();
    _heartbeatWatchdogTimer?.cancel();
    _globalAlertController.close();
    super.dispose();
  }
}
