class RadarDimension {
  final String labelKey;
  final int score; // 0 ~ 100

  const RadarDimension({
    required this.labelKey,
    required this.score,
  });
}

class AnalysisReportData {
  final List<RadarDimension> dimensions;
  final DateTime generatedAt;

  const AnalysisReportData({
    required this.dimensions,
    required this.generatedAt,
  });

  static AnalysisReportData defaultReport() {
    return AnalysisReportData(
      dimensions: const [
        RadarDimension(labelKey: 'skinCleansing', score: 91),
        RadarDimension(labelKey: 'brighteningEffect', score: 83),
        RadarDimension(labelKey: 'oilControl', score: 87),
        RadarDimension(labelKey: 'moisturizing', score: 85),
        RadarDimension(labelKey: 'skinSoothing', score: 92),
      ],
      generatedAt: DateTime.now(),
    );
  }
}
