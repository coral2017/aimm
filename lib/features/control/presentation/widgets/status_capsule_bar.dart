import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/mask_controller.dart';

class StatusCapsuleBar extends StatelessWidget {
  final VoidCallback onConnectionTap;

  const StatusCapsuleBar({
    super.key,
    required this.onConnectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final isConnected = controller.isConnected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Left: Dedicated Add Device (+) Button
          Material(
            color: AppColors.capsuleBackground,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onConnectionTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Center: Status Capsule (Battery, Connection, Timer)
          Expanded(
            child: InkWell(
              onTap: onConnectionTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.capsuleBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Battery
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            isConnected ? Icons.battery_full_rounded : Icons.battery_unknown_rounded,
                            size: 16,
                            color: isConnected ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.batteryLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isConnected ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    // Connection state
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isConnected ? Icons.link_rounded : Icons.link_off_rounded,
                          size: 16,
                          color: isConnected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isConnected ? context.tr('connected') : context.tr('disconnected'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isConnected ? AppColors.primaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Timer / Minutes:Seconds
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: isConnected ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isConnected ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Right: Language Switcher Pill
          InkWell(
            onTap: () => controller.cycleLanguage(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.capsuleBackground,
                borderRadius: BorderRadius.circular(16),
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
                      fontSize: 12,
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
    );
  }
}
