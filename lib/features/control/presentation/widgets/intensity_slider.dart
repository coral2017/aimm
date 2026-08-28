import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/mask_controller.dart';

class IntensitySlider extends StatelessWidget {
  final Function(int targetGear) onHighIntensityRequested;

  const IntensitySlider({
    super.key,
    required this.onHighIntensityRequested,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final isConnected = controller.isConnected;
    final currentGear = controller.currentGear;

    final String gearDisplay = isConnected ? currentGear.toString().padLeft(2, '0') : '--';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        children: [
          // Top Row: Title & Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('intensityLevel'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                gearDisplay,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Control Row: [-] [Slider] [+]
          Row(
            children: [
              // Minus Button
              _buildStepButton(
                icon: Icons.remove_rounded,
                isEnabled: isConnected && currentGear > 1,
                onTap: () {
                  if (currentGear > 1) {
                    controller.setGear(currentGear - 1);
                  }
                },
              ),

              // Slider Track
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: isConnected ? AppColors.primary : AppColors.textMuted,
                      inactiveTrackColor: const Color(0xFFEFECE6),
                      thumbColor: isConnected ? AppColors.primary : AppColors.textMuted,
                      trackHeight: 6.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: Slider(
                      value: isConnected ? currentGear.toDouble() : 1.0,
                      min: 1.0,
                      max: 16.0,
                      divisions: 15,
                      onChanged: isConnected
                          ? (value) {
                              final newGear = value.round();
                              if (newGear > 10 && !controller.hasAcknowledgedHighIntensity) {
                                onHighIntensityRequested(newGear);
                              } else {
                                controller.setGear(newGear);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
              ),

              // Plus Button
              _buildStepButton(
                icon: Icons.add_rounded,
                isEnabled: isConnected && currentGear < 16,
                onTap: () {
                  if (currentGear < 16) {
                    final nextGear = currentGear + 1;
                    if (nextGear > 10 && !controller.hasAcknowledgedHighIntensity) {
                      onHighIntensityRequested(nextGear);
                    } else {
                      controller.setGear(nextGear);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF6F4F0),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
