import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/mask_controller.dart';

class IntensitySlider extends StatefulWidget {
  final Function(int targetGear) onHighIntensityRequested;
  final VoidCallback onBlockedTap;

  const IntensitySlider({
    super.key,
    required this.onHighIntensityRequested,
    required this.onBlockedTap,
  });

  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider> {
  int? _draggingGear;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final isConnected = controller.isConnected;
    final isRunning = controller.isRunning;
    final currentGear = _draggingGear ?? controller.currentGear;

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
                isEnabled: isConnected,
                onTap: () {
                  if (!isRunning) {
                    widget.onBlockedTap();
                    return;
                  }
                  final actualGear = controller.currentGear;
                  if (actualGear > 1) {
                    setState(() {
                      _draggingGear = null;
                    });
                    controller.setGear(actualGear - 1);
                  }
                },
              ),

              // Slider Track
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: isRunning ? AppColors.primary : AppColors.textMuted,
                      inactiveTrackColor: const Color(0xFFEFECE6),
                      thumbColor: isRunning ? AppColors.primary : AppColors.textMuted,
                      trackHeight: 6.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: Slider(
                      value: isConnected ? currentGear.clamp(1, 10).toDouble() : 1.0,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      onChanged: isConnected
                          ? (value) {
                              if (!isRunning) {
                                widget.onBlockedTap();
                                return;
                              }
                              // 滑动过程中仅刷新 UI，不向蓝牙发送高频指令
                              setState(() {
                                _draggingGear = value.round();
                              });
                            }
                          : null,
                      onChangeEnd: isConnected
                          ? (value) {
                              if (!isRunning) {
                                setState(() {
                                  _draggingGear = null;
                                });
                                return;
                              }
                              final newGear = value.round();
                              setState(() {
                                _draggingGear = null;
                              });
                              if (newGear > controller.currentGear && newGear >= 8) {
                                widget.onHighIntensityRequested(newGear);
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
                isEnabled: isConnected,
                onTap: () {
                  if (!isRunning) {
                    widget.onBlockedTap();
                    return;
                  }
                  final actualGear = controller.currentGear;
                  if (actualGear < 10) {
                    final nextGear = actualGear + 1;
                    setState(() {
                      _draggingGear = null;
                    });
                    if (nextGear >= 8) {
                      widget.onHighIntensityRequested(nextGear);
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
