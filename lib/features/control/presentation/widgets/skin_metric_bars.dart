import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/mask_controller.dart';

class SkinMetricBars extends StatelessWidget {
  const SkinMetricBars({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final metrics = controller.skinMetrics;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            label: context.tr('smoothness'),
            value: metrics.smoothness,
            isConnected: controller.isConnected,
          ),
          _buildMetricItem(
            label: context.tr('hydration'),
            value: metrics.hydration,
            isConnected: controller.isConnected,
          ),
          _buildMetricItem(
            label: context.tr('youthfulness'),
            value: metrics.youthfulness,
            isConnected: controller.isConnected,
          ),
          _buildMetricItem(
            label: context.tr('skinTone'),
            value: metrics.skinTone,
            isConnected: controller.isConnected,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required double value,
    required bool isConnected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vertical Progress Capsule Bar
        Container(
          width: 16,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EFE9),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            widthFactor: 1.0,
            heightFactor: isConnected ? value.clamp(0.0, 1.0) : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: isConnected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Metric Label
        SizedBox(
          width: 78,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
