import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/skin_metric_model.dart';
import '../../providers/mask_controller.dart';
import 'skin_water_bar.dart';

class SkinMetricBars extends StatelessWidget {
  const SkinMetricBars({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final metrics = controller.skinMetrics;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SkinWaterBar(
            label: context.tr('smoothness'),
            progress: metrics.smoothness,
            isHighlighted: SkinMetricConfig.isHighlighted(
              mode: controller.currentMode,
              metric: SkinMetricType.delicacy,
              isCombination: controller.isCombinationActive,
            ),
            isAnimating: controller.isRunning,
          ),
          SkinWaterBar(
            label: context.tr('hydration'),
            progress: metrics.hydration,
            isHighlighted: SkinMetricConfig.isHighlighted(
              mode: controller.currentMode,
              metric: SkinMetricType.hydration,
              isCombination: controller.isCombinationActive,
            ),
            isAnimating: controller.isRunning,
          ),
          SkinWaterBar(
            label: context.tr('youthfulness'),
            progress: metrics.youthfulness,
            isHighlighted: SkinMetricConfig.isHighlighted(
              mode: controller.currentMode,
              metric: SkinMetricType.youthfulness,
              isCombination: controller.isCombinationActive,
            ),
            isAnimating: controller.isRunning,
          ),
          SkinWaterBar(
            label: context.tr('skinTone'),
            progress: metrics.skinTone,
            isHighlighted: SkinMetricConfig.isHighlighted(
              mode: controller.currentMode,
              metric: SkinMetricType.clarity,
              isCombination: controller.isCombinationActive,
            ),
            isAnimating: controller.isRunning,
          ),
        ],
      ),
    );
  }
}
