import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleTxLogItem {
  final DateTime timestamp;
  final int mode;
  final int gear;
  final bool isOpen;
  final String hexString;

  BleTxLogItem({
    required this.timestamp,
    required this.mode,
    required this.gear,
    required this.isOpen,
    required this.hexString,
  });

  Map<String, dynamic> toMap() => {
    'time': timestamp.toIso8601String(),
    'mode': mode,
    'gear': gear,
    'isOpen': isOpen,
    'hex': hexString,
  };

  factory BleTxLogItem.fromMap(Map<String, dynamic> map) => BleTxLogItem(
    timestamp: DateTime.tryParse(map['time'] as String? ?? '') ?? DateTime.now(),
    mode: (map['mode'] as num?)?.toInt() ?? 0,
    gear: (map['gear'] as num?)?.toInt() ?? 0,
    isOpen: map['isOpen'] as bool? ?? false,
    hexString: map['hex'] as String? ?? '',
  );

  String toFormattedLine() {
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
    final modeHex = '0x${mode.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final gearHex = '0x${gear.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final stateStr = isOpen ? '开机(ON)' : '关机(OFF)';
    return '[$timeStr] 模式:$modeHex 档位:$gear($gearHex) 运行:$stateStr => $hexString';
  }
}

/// 专用于记录 APP 主机发送指令 (TX) 的日志服务
/// - 隔天自动清空，只保留最新的一天
/// - 同时输出带 '🎯 [BLE_TX_LOG]' 独立标记的控制台日志（方便在 Logcat 中直接单词过滤并一键复制）
class BleTxLogService {
  static const String _keyLogDate = 'ble_tx_log_date';
  static const String _keyLogList = 'ble_tx_log_list';

  static BleTxLogService? _instance;
  static BleTxLogService get instance => _instance ??= BleTxLogService._();
  BleTxLogService._();

  final List<BleTxLogItem> _cachedLogs = [];
  bool _isLoaded = false;

  String _formatTodayDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _checkAndRotateLogs(SharedPreferences prefs) async {
    final today = _formatTodayDate(DateTime.now());
    final savedDate = prefs.getString(_keyLogDate);
    if (savedDate != today) {
      // 隔天清空，只保留最新的一天
      _cachedLogs.clear();
      await prefs.setString(_keyLogDate, today);
      await prefs.remove(_keyLogList);
      _isLoaded = true;
    } else if (!_isLoaded) {
      final listJson = prefs.getString(_keyLogList);
      if (listJson != null && listJson.isNotEmpty) {
        try {
          final List<dynamic> raw = jsonDecode(listJson) as List<dynamic>;
          _cachedLogs.clear();
          for (final item in raw) {
            _cachedLogs.add(BleTxLogItem.fromMap(item as Map<String, dynamic>));
          }
        } catch (_) {}
      }
      _isLoaded = true;
    }
  }

  /// 记录一条发送给下位机的控制指令
  Future<void> recordCommand({
    required int mode,
    required int gear,
    required bool isOpen,
    required Uint8List packet,
  }) async {
    final hexStr = packet.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
    final now = DateTime.now();
    final item = BleTxLogItem(
      timestamp: now,
      mode: mode,
      gear: gear,
      isOpen: isOpen,
      hexString: hexStr,
    );

    // 1. 在控制台打印专属过滤标记：在 Android Studio Logcat 搜索栏只输入 "BLE_TX_LOG" 即可彻底过滤掉所有 RX 干扰！
    debugPrint('🎯 [BLE_TX_LOG] ${item.toFormattedLine()}');

    // 2. 写入内存与 SharedPreferences 本地持久化（隔天自动清空）
    try {
      final prefs = await SharedPreferences.getInstance();
      await _checkAndRotateLogs(prefs);
      _cachedLogs.add(item);
      final jsonStr = jsonEncode(_cachedLogs.map((e) => e.toMap()).toList());
      await prefs.setString(_keyLogList, jsonStr);
    } catch (_) {}
  }

  /// 获取今日的所有发送指令记录
  Future<List<BleTxLogItem>> getTodayLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _checkAndRotateLogs(prefs);
      return List.unmodifiable(_cachedLogs);
    } catch (_) {
      return List.unmodifiable(_cachedLogs);
    }
  }

  /// 导出为整齐的纯文本（方便在 App 内一键复制分享）
  Future<String> exportFormattedText() async {
    final logs = await getTodayLogs();
    if (logs.isEmpty) {
      return '暂无今日主机发送指令';
    }
    final today = _formatTodayDate(DateTime.now());
    final sb = StringBuffer();
    sb.writeln('=== AIMM 主机蓝牙发送指令记录 ($today) ===');
    sb.writeln('共 ${logs.length} 条有效指令:');
    for (int i = 0; i < logs.length; i++) {
      sb.writeln('${(i + 1).toString().padLeft(2, '0')}. ${logs[i].toFormattedLine()}');
    }
    return sb.toString();
  }

  /// 手动清空日志
  Future<void> clearLogs() async {
    _cachedLogs.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLogList);
    } catch (_) {}
  }
}
