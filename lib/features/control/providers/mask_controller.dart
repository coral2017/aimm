import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/ble/ble_device_info.dart';
import '../../../core/ble/ble_manager.dart';
import '../../../core/ble/ble_protocol.dart';
import '../../../core/ble/ble_service_interface.dart';
import '../../../core/storage/device_storage_service.dart';
import '../../../core/storage/report_storage_service.dart';
import '../../report/models/skincare_report_model.dart';
import '../models/mask_mode.dart';

class SavedModePreset {
  final String id;
  final String name;
  final MaskModeType? _mode;
  final bool? _isCombination;
  final int gear;
  final DateTime createdAt;

  SavedModePreset({
    required this.id,
    required this.name,
    MaskModeType? mode,
    bool? isCombination = false,
    required this.gear,
    required this.createdAt,
  })  : _mode = mode,
        _isCombination = isCombination;

  bool get isCombination => _isCombination == true;
  MaskModeType get mode => _mode ?? MaskModeType.firming;
  IconData get displayIcon => isCombination ? Icons.layers_rounded : mode.icon;
  String get displayTitleKey => isCombination ? 'combination' : mode.l10nKey;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'modeId': isCombination ? -1 : mode.id,
      'isCombination': isCombination,
      'gear': gear,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedModePreset.fromMap(Map<String, dynamic> map) {
    final isCombination = map['isCombination'] == true;
    final modeId = map['modeId'] as int? ?? 0;
    return SavedModePreset(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? '',
      isCombination: isCombination,
      mode: isCombination ? null : MaskModeType.fromId(modeId),
      gear: (map['gear'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
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
  DateTime? _lastTreatmentCompleteTime;

  MaskModeType? _selectedMode; // Nullable: unselected upon connection
  int _currentGear = 1; // Default initial gear is 1 (Range: 1 ~ 10)
  bool _isPowerOn = false; // Default initial state is Stopped
  int _batteryPercent = 80;

  // Current Dispatched BLE Hardware Gear
  int? _dispatchedBleGear;

  @visibleForTesting
  int? get dispatchedBleGear => _dispatchedBleGear;

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

  // Skincare Treatment Session Lifecycle
  DateTime? _sessionStartTime;
  DateTime? _sessionLastPausedTime;
  int _sessionAccumulatedSeconds = 0;
  int _sessionMaxGear = 1;
  int _sessionGearSum = 0;
  int _sessionGearCount = 0;
  SkincareReportModel? _latestReport;

  SkincareReportModel? get latestReport => _latestReport;
  @visibleForTesting
  int get sessionAccumulatedSeconds => _sessionAccumulatedSeconds;

  final List<SavedModePreset> _savedPresets = [];

  MaskController() {
    _initBleListeners();
    _startHeartbeatWatchdog();
    _loadBoundDeviceAndAutoConnect();
    _loadSavedPresets();
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
  int get maxGearLimit => maxGear;
  List<SavedModePreset> get savedPresets => List.unmodifiable(_savedPresets);

  /// Checks if current mode & gear have already been saved
  bool get isCurrentSaved {
    if (_isCombinationActive) {
      return _savedPresets.any((p) => p.isCombination && p.gear == _currentGear);
    }
    if (_selectedMode == null) return false;
    return _savedPresets.any((p) => !p.isCombination && p.mode == _selectedMode && p.gear == _currentGear);
  }
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
        _dispatchedBleGear = null;
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
        _dispatchedBleGear = null;
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
      final elapsedSinceComplete = _lastTreatmentCompleteTime != null
          ? DateTime.now().difference(_lastTreatmentCompleteTime!).inMilliseconds
          : 99999;

      // 如果 App 本地未启动，且并非刚刚由 App 主动下发暂停或护理刚完成（避免飞行中的旧报文误唤醒），直接同步接续从机的运行状态与时间
      if (!_isPowerOn) {
        // 防护拦截：刚完成一轮护理(5秒内)、刚刚暂停(1.5秒内)、或MCU剩余时间已耗尽(<=3秒)时，严禁误触发开机接续
        if (elapsedSincePause <= 1500 || elapsedSinceComplete <= 5000 || mcuRemainingSeconds <= 3) {
          debugPrint('🛡️ [忽略从机接续] 拦截刚完成/已耗尽/刚刚暂停的飞行残余报文 (完成间隔: ${elapsedSinceComplete}ms, 暂停间隔: ${elapsedSincePause}ms, MCU剩余: ${mcuRemainingSeconds}s)');
          return;
        }

        debugPrint('🔄 [从机状态接续] 从机正在运行中，同步接续运行状态与时间: ${report.workMinutes}分${report.workSeconds}秒 (模式: ${report.mode}, 档位: ${report.gear})');
        _isPowerOn = true;
        _remainingSecondsTotal = mcuRemainingSeconds > 0 ? mcuRemainingSeconds : totalTreatmentSeconds;

        // 若此前未选模式且未进入综合模式，尝试根据从机模式值恢复
        if (_selectedMode == null && !_isCombinationActive) {
          _selectedMode = MaskModeType.fromFirmwareValue(report.mode);
          _currentGear = _selectedMode!.getUiGearFromBle(report.gear);
          _dispatchedBleGear = report.gear;
        }
        if (_skinMetrics.isEmpty) {
          _skinMetrics = SkinMetricData.initialBaseline;
        }
        _startCountdown();
      } else {
        // 如果已经在运行中，与下位机时间偏差平滑对齐
        final elapsedSinceStart = _lastStartRequestTime != null
            ? DateTime.now().difference(_lastStartRequestTime!).inSeconds
            : 9999;

        // 核心防护：在刚启动的前 5 秒内，如果下位机上报的剩余时间极短 (<= 60 秒)，
        // 100% 是上一轮护理刚结束时固件时钟还未完全重载到12分钟的旧残留时钟，严禁向下同步！
        if (elapsedSinceStart < 5 && mcuRemainingSeconds <= 60) {
          debugPrint('🛡️ [时钟对齐保护] 启动初期($elapsedSinceStart秒)下位机上报时间异常($mcuRemainingSeconds秒)，忽略上一轮残留的耗尽时钟');
        } else if (mcuRemainingSeconds > 3 && (_remainingSecondsTotal - mcuRemainingSeconds).abs() > 3) {
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
          _dispatchedBleGear = null;
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

    if (_remainingSecondsTotal <= 10) {
      _remainingSecondsTotal = totalTreatmentSeconds;
    }

    // Do NOT stop countdown or pause power if currently running!
    notifyListeners();

    if (isConnected) {
      _dispatchedBleGear = mode.startGear;
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

    if (_remainingSecondsTotal <= 10) {
      _remainingSecondsTotal = totalTreatmentSeconds;
      _skinMetrics = SkinMetricData.initialBaseline;
    }

    final elapsed = totalTreatmentSeconds - _remainingSecondsTotal;
    _combinationCurrentStage = (elapsed ~/ 120).clamp(0, 5);
    final targetMode = _combinationSequence[_combinationCurrentStage];

    debugPrint('👉 [App UI 操作] 切换到综合模式 (阶段: ${_combinationCurrentStage + 1}/6, 底层模式: ${targetMode.name}, 运行中: $_isPowerOn, 剩余时间: $_remainingSecondsTotal秒)');

    notifyListeners();

    if (isConnected) {
      final bleGear = targetMode.getBleGear(1);
      _dispatchedBleGear = bleGear;
      await _bleManager.sendControl(
        mode: targetMode.firmwareValue,
        gear: bleGear,
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
    _dispatchedBleGear = targetBleGear;
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
      // Transition from Running -> Paused (Immediate 0-latency safety cut-off)
      _dispatchedBleGear = null;
      _isPowerOn = false;
      _lastPauseRequestTime = DateTime.now();
      _sessionLastPausedTime = DateTime.now();
      _stopCountdown();
    } else {
      // Transition from Paused/Stopped -> Running
      _lastPauseRequestTime = null;
      _lastTreatmentCompleteTime = null;
      // Safety rule: Always reset gear to 1 when restarting to prevent sudden high-intensity surge!
      _currentGear = 1;

      // 如果剩余时间处于耗尽临界(<= 10秒)或水柱为空，视为新一轮护理，重置为满 12 分钟 (720秒)
      if (_remainingSecondsTotal <= 10 || _skinMetrics.isEmpty) {
        _remainingSecondsTotal = totalTreatmentSeconds;
        _skinMetrics = SkinMetricData.initialBaseline;
      }
      _isPowerOn = true;
      _lastStartRequestTime = DateTime.now();
      _startOrResumeSession();
      _startCountdown();
    }

    final underlying = activeUnderlyingMode;
    final targetBleGear = underlying.getBleGear(_currentGear);
    debugPrint('👉 [App UI 操作] 点击【${targetPower ? "开始运行" : "暂停运行"}】 (模式: ${underlying.name}[FW:0x${underlying.firmwareValue.toRadixString(16)}], UI档位: $_currentGear -> BLE通信档位: $targetBleGear)');

    notifyListeners();

    if (_isPowerOn) {
      _dispatchedBleGear = targetBleGear;
      await _bleManager.sendControl(
        mode: underlying.firmwareValue,
        gear: targetBleGear,
        isOpen: true,
      );
    } else {
      _dispatchedBleGear = null;
      await _bleManager.sendControl(
        mode: underlying.firmwareValue,
        gear: targetBleGear,
        isOpen: false,
      );
    }
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
        _sessionAccumulatedSeconds++;
        _sessionMaxGear = max(_sessionMaxGear, _currentGear);
        _sessionGearSum += _currentGear;
        _sessionGearCount++;

        // Calculate dynamic skin metrics filling per second (Tick = 1s)
        final elapsedSeconds = totalTreatmentSeconds - _remainingSecondsTotal;
        final phaseFactor = SkinMetricConfig.getPhaseFactor(elapsedSeconds);
        final gearFactor = SkinMetricConfig.getGearFactor(_currentGear);
        const vBase = SkinMetricConfig.vBase;

        // In both single and combination mode, dynamically follow activeUnderlyingMode's distinct weights!
        final weights = SkinMetricConfig.modeWeights[activeUnderlyingMode] ?? SkinMetricConfig.combinationWeights;

        final deltaDelicacy = vBase * (weights[SkinMetricType.delicacy] ?? 1.0) * phaseFactor * gearFactor;
        final deltaHydration = vBase * (weights[SkinMetricType.hydration] ?? 1.0) * phaseFactor * gearFactor;
        final deltaYouthfulness = vBase * (weights[SkinMetricType.youthfulness] ?? 1.0) * phaseFactor * gearFactor;
        final deltaClarity = vBase * (weights[SkinMetricType.clarity] ?? 1.0) * phaseFactor * gearFactor;

        var newSmoothness = _skinMetrics.smoothness + deltaDelicacy;
        var newHydration = _skinMetrics.hydration + deltaHydration;
        var newYouthfulness = _skinMetrics.youthfulness + deltaYouthfulness;
        var newSkinTone = _skinMetrics.skinTone + deltaClarity;

        // 动态硬底保护：最大与最小指标间距控制在 15% (0.15) 以内
        final maxVal = max(
          max(newSmoothness, newHydration),
          max(newYouthfulness, newSkinTone),
        );
        final minFloor = maxVal - 0.15;

        _skinMetrics = _skinMetrics.copyWith(
          smoothness: max(newSmoothness, minFloor).clamp(0.0, 0.98),
          hydration: max(newHydration, minFloor).clamp(0.0, 0.98),
          youthfulness: max(newYouthfulness, minFloor).clamp(0.0, 0.98),
          skinTone: max(newSkinTone, minFloor).clamp(0.0, 0.98),
        );

        // If in combination mode, check if we need to advance to next 2-minute stage
        if (_isCombinationActive && _combinationSequence.isNotEmpty) {
          final targetStage = (elapsedSeconds ~/ 120).clamp(0, _combinationSequence.length - 1);
          if (targetStage != _combinationCurrentStage) {
            _combinationCurrentStage = targetStage;
            final stageMode = _combinationSequence[targetStage];
            final stageBleGear = stageMode.getBleGear(_currentGear);
            _dispatchedBleGear = stageBleGear;
            _bleManager.sendControl(
              mode: stageMode.firmwareValue,
              gear: stageBleGear,
              isOpen: true,
            );
          }
        }
        notifyListeners();
      } else {
        _onTreatmentCompleted();
      }
    });
  }

  void _onTreatmentCompleted() {
    _dispatchedBleGear = null;
    _isPowerOn = false;
    _isCombinationActive = false;
    _stopCountdown();
    _remainingSecondsTotal = totalTreatmentSeconds; // Reset to 12:00 for next session
    _lastTreatmentCompleteTime = DateTime.now();
    _lastPauseRequestTime = DateTime.now();
    _globalAlertController.add('treatmentCompleteAlert');
    unawaited(_finalizeAndSaveSession(isCompleted: true));

    // 【重置皮肤指标水柱与模式选中态】
    _skinMetrics = SkinMetricData.empty;
    _selectedMode = null;
    _currentGear = 1;
    notifyListeners();

    final underlying = activeUnderlyingMode;
    _bleManager.sendControl(
      mode: underlying.firmwareValue,
      gear: underlying.getBleGear(_currentGear),
      isOpen: false,
    );
  }

  @visibleForTesting
  void triggerTreatmentCompleteForTesting() => _onTreatmentCompleted();

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

  /// Unpair from current device (clears saved device pairing)
  Future<void> unpairCurrentDevice() async {
    await unbindCurrentDevice();
  }

  /// Unbind / Disconnect from current device
  Future<void> unbindCurrentDevice() async {
    debugPrint('👉 [App UI 操作] 解除配对/断开设备');
    await _finalizeAndSaveSession(isCompleted: false);
    _dispatchedBleGear = null;
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

  Future<void> saveCurrentPreset(String name) async {
    if (_isCombinationActive) {
      await savePreset(isCombination: true, gear: _currentGear, customName: name);
    } else {
      final mode = _selectedMode ?? currentMode;
      await savePreset(mode: mode, gear: _currentGear, customName: name);
    }
  }

  Future<void> savePreset({
    MaskModeType? mode,
    bool isCombination = false,
    required int gear,
    String? customName,
  }) async {
    final clampedGear = gear.clamp(1, maxGear);
    final existingIndex = _savedPresets.indexWhere((p) =>
        isCombination
            ? (p.isCombination && p.gear == clampedGear)
            : (!p.isCombination && p.mode == mode && p.gear == clampedGear));
    if (existingIndex >= 0) {
      debugPrint('ℹ️ [预设保存] 该模式与档位已存在于保存列表中 (combination: $isCombination, mode: ${mode?.name}, gear: $clampedGear)');
      return;
    }

    final defaultName = isCombination
        ? '综合模式 · L$clampedGear'
        : '${mode?.l10nKey ?? ""} · L$clampedGear';
    final displayName = customName?.trim().isNotEmpty == true
        ? customName!.trim()
        : defaultName;

    final newPreset = SavedModePreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: displayName,
      mode: isCombination ? null : mode,
      isCombination: isCombination,
      gear: clampedGear,
      createdAt: DateTime.now(),
    );

    _savedPresets.insert(0, newPreset);
    notifyListeners();
    await _persistSavedPresets();
    debugPrint('💾 [预设保存] 成功保存预设: ${newPreset.name} (共 ${_savedPresets.length} 项)');
  }

  Future<void> applyPresetAndStart(SavedModePreset preset) async {
    debugPrint('🚀 [应用并运行预设] 模式: ${preset.isCombination ? "综合模式" : preset.mode.name}, 档位: ${preset.gear}');
    if (preset.isCombination) {
      await switchToCombinationMode();
      _currentGear = preset.gear;
      notifyListeners();

      if (isConnected) {
        if (!_isPowerOn) {
          await togglePower();
        }
        await setGear(preset.gear);
      }
    } else {
      setMode(preset.mode);
      _currentGear = preset.gear;
      notifyListeners();

      if (isConnected) {
        if (!_isPowerOn) {
          await togglePower();
        }
        await setGear(preset.gear);
      }
    }
  }

  void applyPreset(SavedModePreset preset) {
    applyPresetAndStart(preset);
  }

  Future<void> deletePreset(String id) async {
    _savedPresets.removeWhere((p) => p.id == id);
    notifyListeners();
    await _persistSavedPresets();
  }

  Future<void> _persistSavedPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = jsonEncode(_savedPresets.map((p) => p.toMap()).toList());
      await prefs.setString('aimm_saved_mode_presets', listJson);
    } catch (_) {}
  }

  Future<void> _loadSavedPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getString('aimm_saved_mode_presets');
      if (listJson != null && listJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(listJson) as List<dynamic>;
        _savedPresets.clear();
        for (final item in decoded) {
          _savedPresets.add(SavedModePreset.fromMap(item as Map<String, dynamic>));
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  void _startOrResumeSession() {
    final now = DateTime.now();
    if (_sessionStartTime != null && _sessionLastPausedTime != null) {
      final pauseGapMinutes = now.difference(_sessionLastPausedTime!).inMinutes;
      if (pauseGapMinutes < 5) {
        debugPrint('🔄 [护肤会话接续] 在5分钟接续窗口内（已暂停${now.difference(_sessionLastPausedTime!).inSeconds}秒），继续累加有效时长 (已累计: $_sessionAccumulatedSeconds 秒)');
        _sessionLastPausedTime = null;
        return;
      } else {
        // Gap >= 5 minutes: previous session timed out, finalize it
        _finalizeAndSaveSession(isCompleted: false);
      }
    }

    // Start fresh session
    _sessionStartTime = now;
    _sessionAccumulatedSeconds = 0;
    _sessionMaxGear = _currentGear;
    _sessionGearSum = _currentGear;
    _sessionGearCount = 1;
    _sessionLastPausedTime = null;
    debugPrint('✨ [新护肤会话开启] 记录开始时间: $_sessionStartTime, 模式: ${activeUnderlyingMode.name}, 起始档位: $_currentGear');
  }

  Future<void> _finalizeAndSaveSession({required bool isCompleted}) async {
    if (_sessionStartTime == null || _sessionAccumulatedSeconds < 60) {
      if (_sessionStartTime != null && _sessionAccumulatedSeconds < 60) {
        debugPrint('⚠️ [护肤会话丢弃] 有效运行时间过短 ($_sessionAccumulatedSeconds 秒 < 60秒)，视为误触丢弃');
      }
      _resetSession();
      return;
    }

    final avgGear = _sessionGearCount > 0
        ? (_sessionGearSum / _sessionGearCount)
        : _currentGear.toDouble();
    final score = SkincareReportModel.calculateScore(
      smoothness: _skinMetrics.smoothness,
      hydration: _skinMetrics.hydration,
      youthfulness: _skinMetrics.youthfulness,
      skinTone: _skinMetrics.skinTone,
    );

    final modeKey = _isCombinationActive ? 'combination' : activeUnderlyingMode.name;
    final modeName = _isCombinationActive ? '综合模式' : activeUnderlyingMode.l10nKey;

    // 单次护理最大时长上限钳位至标准12分钟(720秒)，消除蓝牙时间同步及重试导致的数秒毛刺
    final cappedDuration = min(_sessionAccumulatedSeconds, totalTreatmentSeconds);

    final report = SkincareReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      actualDurationSeconds: cappedDuration,
      modeKey: modeKey,
      modeName: modeName,
      maxGear: _sessionMaxGear,
      avgGear: double.parse(avgGear.toStringAsFixed(1)),
      smoothness: _skinMetrics.smoothness,
      hydration: _skinMetrics.hydration,
      youthfulness: _skinMetrics.youthfulness,
      skinTone: _skinMetrics.skinTone,
      score: score,
      isCompleted: isCompleted,
    );

    _latestReport = report;
    await ReportStorageService.instance.saveReport(report);
    debugPrint('📊 [护肤报告归档] 成功生成并持久化护肤记录: ${report.formattedDuration}, 得分: ${report.score}, 模式: ${report.modeKey}, 完整完成: $isCompleted');
    _resetSession();
  }

  void _resetSession() {
    _sessionStartTime = null;
    _sessionLastPausedTime = null;
    _sessionAccumulatedSeconds = 0;
    _sessionMaxGear = 1;
    _sessionGearSum = 0;
    _sessionGearCount = 0;
  }

  @visibleForTesting
  Future<void> finalizeAndSaveSessionForTesting({required bool isCompleted}) =>
      _finalizeAndSaveSession(isCompleted: isCompleted);

  @visibleForTesting
  void simulateSessionSecondsForTesting(int seconds) {
    _sessionAccumulatedSeconds += seconds;
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
