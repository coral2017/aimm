import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../control/providers/mask_controller.dart';
import '../models/report_model.dart';
import '../models/skincare_report_model.dart';
import 'widgets/analysis_card.dart';
import 'widgets/radar_chart_widget.dart';

class AnalysisReportPage extends StatelessWidget {
  final SkincareReportModel? report;

  const AnalysisReportPage({
    super.key,
    this.report,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final activeReport = report ?? controller.latestReport;

    int smoothnessScore;
    int youthfulnessScore;
    int hydrationScore;
    int skinToneScore;
    int overallScore;

    if (activeReport != null) {
      smoothnessScore = (activeReport.smoothness * 100).round().clamp(10, 99);
      youthfulnessScore = (activeReport.youthfulness * 100).round().clamp(10, 99);
      hydrationScore = (activeReport.hydration * 100).round().clamp(10, 99);
      skinToneScore = (activeReport.skinTone * 100).round().clamp(10, 99);
      overallScore = activeReport.score;
    } else if (!controller.skinMetrics.isEmpty) {
      smoothnessScore = (controller.skinMetrics.smoothness * 100).round().clamp(10, 99);
      youthfulnessScore = (controller.skinMetrics.youthfulness * 100).round().clamp(10, 99);
      hydrationScore = (controller.skinMetrics.hydration * 100).round().clamp(10, 99);
      skinToneScore = (controller.skinMetrics.skinTone * 100).round().clamp(10, 99);
      overallScore = SkincareReportModel.calculateScore(
        smoothness: controller.skinMetrics.smoothness,
        hydration: controller.skinMetrics.hydration,
        youthfulness: controller.skinMetrics.youthfulness,
        skinTone: controller.skinMetrics.skinTone,
      );
    } else {
      smoothnessScore = 91;
      youthfulnessScore = 83;
      hydrationScore = 87;
      skinToneScore = 85;
      overallScore = 88;
    }

    final radarData = AnalysisReportData(
      dimensions: [
        RadarDimension(labelKey: 'skinCleansing', score: smoothnessScore),
        RadarDimension(labelKey: 'brighteningEffect', score: skinToneScore),
        RadarDimension(labelKey: 'oilControl', score: hydrationScore),
        RadarDimension(labelKey: 'moisturizing', score: ((hydrationScore + smoothnessScore) ~/ 2)),
        RadarDimension(labelKey: 'skinSoothing', score: youthfulnessScore),
      ],
      generatedAt: activeReport?.endTime ?? DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('aiReportTitle'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // If viewing a concrete session report, show a summary card
            if (activeReport != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$overallScore',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                activeReport.modeKey == 'combination'
                                    ? context.tr('combination')
                                    : (context.tr(activeReport.modeKey) != activeReport.modeKey
                                        ? context.tr(activeReport.modeKey)
                                        : activeReport.modeName),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: activeReport.isCompleted
                                      ? Colors.green.withValues(alpha: 0.12)
                                      : Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  activeReport.isCompleted
                                      ? context.tr('completed')
                                      : context.tr('partialSession'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: activeReport.isCompleted
                                        ? Colors.green.shade700
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${context.tr('duration')}: ${activeReport.formattedDuration}  •  ${context.tr('intensityLevel')}: ${activeReport.maxGear}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 5-Axis Pentagon Radar Chart
            RadarChartWidget(dimensions: radarData.dimensions),

            const SizedBox(height: 12),

            // Analysis Report Sheet Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Top Bronze Decorative Tab Badge
                  Positioned(
                    top: -12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        context.tr('analysisReport'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Detail Content Cards List
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Smoothness
                        AnalysisCard(
                          icon: Icons.sentiment_satisfied_alt_rounded,
                          title: context.tr('smoothness'),
                          description: context.tr('reportSmoothnessDesc'),
                          tag1Label: context.tr('skinCleansing'),
                          tag1Score: smoothnessScore,
                          tag2Label: context.tr('skinSoothing'),
                          tag2Score: (smoothnessScore * 0.98).round(),
                        ),

                        // Card 2: Youthfulness
                        AnalysisCard(
                          icon: Icons.hub_outlined,
                          title: context.tr('youthfulness'),
                          description: context.tr('reportYouthfulnessDesc'),
                          tag1Label: context.tr('firmness'),
                          tag1Score: youthfulnessScore,
                          tag2Label: context.tr('skinElasticity'),
                          tag2Score: (youthfulnessScore * 0.97).round(),
                        ),

                        // Card 3: Hydration
                        AnalysisCard(
                          icon: Icons.lightbulb_outline,
                          title: context.tr('hydration'),
                          description: context.tr('reportHydrationDesc'),
                          tag1Label: context.tr('oilControl'),
                          tag1Score: hydrationScore,
                          tag2Label: context.tr('moisturizing'),
                          tag2Score: (hydrationScore * 0.96).round(),
                        ),

                        // Card 4: Skin Tone
                        AnalysisCard(
                          icon: Icons.waves,
                          title: context.tr('skinTone'),
                          description: context.tr('reportSkinToneDesc'),
                          tag1Label: context.tr('brighteningEffect'),
                          tag1Score: skinToneScore,
                          tag2Label: context.tr('evenSkinTone'),
                          tag2Score: (skinToneScore * 0.95).round(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
