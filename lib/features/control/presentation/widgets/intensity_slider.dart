import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/mask_controller.dart';

class IntensitySlider extends StatefulWidget {
  final Function(int targetGear) onHighIntensityRequested;
  final VoidCallback onBlockedTap;
  final VoidCallback? onNotConnectedTap;

  const IntensitySlider({
    super.key,
    required this.onHighIntensityRequested,
    required this.onBlockedTap,
    this.onNotConnectedTap,
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
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
                  color: AppColors.textSecondary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bottom Control Row: [-] [Slider] [+]
          Row(
            children: [
              // Minus Button
              _buildStepButton(
                icon: Icons.remove_rounded,
                isInteractive: isConnected && isRunning,
                onTap: () {
                  if (!isConnected) {
                    widget.onNotConnectedTap?.call();
                    return;
                  }
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

              // Slider Track: 18px thick capsule track per Figma design
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 18.0,
                          trackShape: const RoundedRectSliderTrackShape(),
                          activeTrackColor: isConnected ? AppColors.sliderTrackActive : AppColors.sliderTrackInactive,
                          inactiveTrackColor: AppColors.sliderTrackInactive,
                          thumbColor: isConnected ? AppColors.sliderThumb : AppColors.textMuted,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 9.0,
                            elevation: 2.0,
                          ),
                          overlayColor: AppColors.sliderThumb.withValues(alpha: 0.15),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 18.0),
                        ),
                        child: Slider(
                          value: isConnected ? currentGear.clamp(1, 10).toDouble() : 1.0,
                          min: 1.0,
                          max: 10.0,
                          divisions: 9,
                          onChanged: isConnected && isRunning
                              ? (value) {
                                  // 滑动过程中仅刷新 UI，不向蓝牙发送高频指令
                                  setState(() {
                                    _draggingGear = value.round();
                                  });
                                }
                              : null,
                          onChangeEnd: isConnected && isRunning
                              ? (value) {
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

                      // 未连接或未运行时覆盖透明手势层，精准拦截点击与拖拽，给予清晰友好的操作指引
                      if (!isConnected || !isRunning)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (!isConnected) {
                                widget.onNotConnectedTap?.call();
                              } else {
                                widget.onBlockedTap();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Plus Button
              _buildStepButton(
                icon: Icons.add_rounded,
                isInteractive: isConnected && isRunning,
                onTap: () {
                  if (!isConnected) {
                    widget.onNotConnectedTap?.call();
                    return;
                  }
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
    required bool isInteractive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.sliderButton,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder, width: 0.8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isInteractive ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
