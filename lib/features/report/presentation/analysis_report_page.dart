import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/report_model.dart';
import 'widgets/analysis_card.dart';
import 'widgets/radar_chart_widget.dart';

class AnalysisReportPage extends StatelessWidget {
  const AnalysisReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reportData = AnalysisReportData.defaultReport();

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

            // 5-Axis Pentagon Radar Chart
            RadarChartWidget(dimensions: reportData.dimensions),

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
                          tag1Score: 91,
                          tag2Label: context.tr('skinSoothing'),
                          tag2Score: 92,
                        ),

                        // Card 2: Youthfulness
                        AnalysisCard(
                          icon: Icons.hub_outlined,
                          title: context.tr('youthfulness'),
                          description: context.tr('reportYouthfulnessDesc'),
                          tag1Label: context.tr('brighteningEffect'),
                          tag1Score: 82,
                          tag2Label: context.tr('evenSkinTone'),
                          tag2Score: 84,
                        ),

                        // Card 3: Hydration
                        AnalysisCard(
                          icon: Icons.lightbulb_outline,
                          title: context.tr('hydration'),
                          description: context.tr('reportHydrationDesc'),
                          tag1Label: context.tr('oilControl'),
                          tag1Score: 87,
                          tag2Label: context.tr('moisturizing'),
                          tag2Score: 85,
                        ),

                        // Card 4: Skin Tone
                        AnalysisCard(
                          icon: Icons.waves,
                          title: context.tr('skinTone'),
                          description: context.tr('reportSkinToneDesc'),
                          tag1Label: context.tr('brighteningEffect'),
                          tag1Score: 86,
                          tag2Label: context.tr('evenSkinTone'),
                          tag2Score: 80,
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
