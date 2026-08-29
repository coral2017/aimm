import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../connection/presentation/connected_device_dialog.dart';
import '../../../connection/presentation/device_connection_dialog.dart';
import '../../providers/mask_controller.dart';

class StatusMetricCard extends StatelessWidget {
  const StatusMetricCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final isConnected = controller.isConnected;
    final metrics = controller.skinMetrics;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
      child: Column(
        children: [
          // Top Row: [Status Capsule OR + bind Button] ... [Language Pill]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isConnected)
                // Unbound / Disconnected: + bind button (Figma 18:591)
                InkWell(
                  onTap: () => DeviceConnectionDialog.show(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('bind'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Connected: Status Capsule (Battery, Connected, Timer) -> Opens ConnectedDeviceDialog (Figma 0:810)
                InkWell(
                  onTap: () => ConnectedDeviceDialog.show(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.capsuleBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Battery
                        const Icon(
                          Icons.battery_charging_full_rounded,
                          size: 15,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.batteryLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Connected badge
                        const Icon(
                          Icons.link_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('connected'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Timer
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.formattedTime,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Right: Language Pill (🌐 EN / 简体)
              InkWell(
                onTap: () => controller.cycleLanguage(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.capsuleBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.loc.currentLanguageLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4 Vertical Metric Progress Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                label: context.tr('smoothness'),
                value: metrics.smoothness,
                isConnected: isConnected,
              ),
              _buildMetricItem(
                label: context.tr('hydration'),
                value: metrics.hydration,
                isConnected: isConnected,
              ),
              _buildMetricItem(
                label: context.tr('youthfulness'),
                value: metrics.youthfulness,
                isConnected: isConnected,
              ),
              _buildMetricItem(
                label: context.tr('skinTone'),
                value: metrics.skinTone,
                isConnected: isConnected,
              ),
            ],
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
          height: 64,
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
          width: 76,
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
