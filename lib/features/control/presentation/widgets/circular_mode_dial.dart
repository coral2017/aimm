import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/mask_mode.dart';
import '../../providers/mask_controller.dart';

class CircularModeDial extends StatelessWidget {
  final VoidCallback onSaveTap;
  final VoidCallback onCombinationTap;

  const CircularModeDial({
    super.key,
    required this.onSaveTap,
    required this.onCombinationTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final currentMode = controller.currentMode;
    final isConnected = controller.isConnected;
    final isPowerOn = controller.isPowerOn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          const Text(
            'Beauty Hub',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          // Center Circular Mode Selector
          Center(
            child: SizedBox(
              width: 270,
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Faint Ring
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF2EEE9),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // 6 Mode Nodes positioned around circle
                  ...MaskModeType.values.map((mode) {
                    return _buildModeNode(
                      context: context,
                      mode: mode,
                      isSelected: currentMode == mode,
                      onTap: () => controller.setMode(mode),
                    );
                  }),

                  // Center Power / Start Button
                  _buildCenterPowerButton(
                    context: context,
                    isPowerOn: isPowerOn && isConnected,
                    onTap: () => controller.togglePower(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Bottom Action Row (Save & Combination)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Save Button
              InkWell(
                onTap: onSaveTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bookmark_border_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('save'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Combination Button
              InkWell(
                onTap: onCombinationTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.layers_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('combination'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeNode({
    required BuildContext context,
    required MaskModeType mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // 6 modes placed at angles:
    // Rejuvenating: -90° (top)
    // Firming: -30° (top-right)
    // Lifting: +30° (bottom-right)
    // IntensiveCare: +90° (bottom)
    // Revitalizing: +150° (bottom-left)
    // Plumping: +210° (top-left)
    final double angleInDegrees = switch (mode) {
      MaskModeType.rejuvenating => -90.0,
      MaskModeType.firming => -30.0,
      MaskModeType.lifting => 30.0,
      MaskModeType.intensiveCare => 90.0,
      MaskModeType.revitalizing => 150.0,
      MaskModeType.plumping => 210.0,
    };

    final double radius = 105.0; // Distance from center
    final double angleInRadians = angleInDegrees * (math.pi / 180.0);
    final double x = radius * math.cos(angleInRadians);
    final double y = radius * math.sin(angleInRadians);

    return Transform.translate(
      offset: Offset(x, y),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mode.icon,
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(mode.l10nKey),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPowerButton({
    required BuildContext context,
    required bool isPowerOn,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPowerOn ? AppColors.primaryGradient : AppColors.inactiveGradient,
          boxShadow: [
            if (isPowerOn)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            else
              const BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.power_settings_new_rounded,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(height: 3),
            Text(
              isPowerOn ? context.tr('start') : context.tr('stop'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
