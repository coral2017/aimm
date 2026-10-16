import 'dart:convert';

/// Represents a finalized skincare treatment session record.
class SkincareReportModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int actualDurationSeconds; // Total effective treatment runtime in seconds
  final String modeKey; // e.g. 'rejuvenating', 'plumping', 'combination'
  final String modeName; // Display name
  final int maxGear; // Highest gear reached (1~10)
  final double avgGear; // Average gear during treatment
  final double smoothness; // 细腻度 (0.0 ~ 1.0)
  final double hydration; // 润泽度 (0.0 ~ 1.0)
  final double youthfulness; // 年轻度 (0.0 ~ 1.0)
  final double skinTone; // 匀净度 (0.0 ~ 1.0)
  final int score; // Overall composite score (0 ~ 100)
  final bool isCompleted; // Whether reached full target duration (12 min)

  const SkincareReportModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.actualDurationSeconds,
    required this.modeKey,
    required this.modeName,
    required this.maxGear,
    required this.avgGear,
    required this.smoothness,
    required this.hydration,
    required this.youthfulness,
    required this.skinTone,
    required this.score,
    required this.isCompleted,
  });

  /// Duration formatted as "X min" or "Xm Ys"
  String get formattedDuration {
    final m = actualDurationSeconds ~/ 60;
    final s = actualDurationSeconds % 60;
    if (s == 0) {
      return '$m min';
    }
    return '$m min $s s';
  }

  /// Calculates a 0-100 score from the 4 skin metric dimensions
  static int calculateScore({
    required double smoothness,
    required double hydration,
    required double youthfulness,
    required double skinTone,
  }) {
    final avg = (smoothness + hydration + youthfulness + skinTone) / 4.0;
    return (avg * 100).round().clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'actualDurationSeconds': actualDurationSeconds,
      'modeKey': modeKey,
      'modeName': modeName,
      'maxGear': maxGear,
      'avgGear': avgGear,
      'smoothness': smoothness,
      'hydration': hydration,
      'youthfulness': youthfulness,
      'skinTone': skinTone,
      'score': score,
      'isCompleted': isCompleted,
    };
  }

  factory SkincareReportModel.fromMap(Map<String, dynamic> map) {
    return SkincareReportModel(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.tryParse(map['startTime'] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] as String? ?? '') ?? DateTime.now(),
      actualDurationSeconds: (map['actualDurationSeconds'] as num?)?.toInt() ?? 0,
      modeKey: map['modeKey'] as String? ?? 'rejuvenating',
      modeName: map['modeName'] as String? ?? '',
      maxGear: (map['maxGear'] as num?)?.toInt() ?? 1,
      avgGear: (map['avgGear'] as num?)?.toDouble() ?? 1.0,
      smoothness: (map['smoothness'] as num?)?.toDouble() ?? 0.0,
      hydration: (map['hydration'] as num?)?.toDouble() ?? 0.0,
      youthfulness: (map['youthfulness'] as num?)?.toDouble() ?? 0.0,
      skinTone: (map['skinTone'] as num?)?.toDouble() ?? 0.0,
      score: (map['score'] as num?)?.toInt() ?? 80,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SkincareReportModel.fromJson(String source) =>
      SkincareReportModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
