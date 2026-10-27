import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/mask_mode.dart';
import '../../providers/mask_controller.dart';
import 'beauty_hub_icons.dart';
import 'celestial_orbital_ring.dart';
import '../../../../core/widgets/app_feedback.dart';

class CircularModeDial extends StatefulWidget {
  final VoidCallback onSaveTap;
  final VoidCallback onCombinationTap;

  const CircularModeDial({
    super.key,
    required this.onSaveTap,
    required this.onCombinationTap,
  });

  @override
  State<CircularModeDial> createState() => _CircularModeDialState();
}

class _CircularModeDialState extends State<CircularModeDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    // 呼吸光晕动画：周期 2.4 秒，更显著的深呼吸起伏（1.0 ~ 0.38）
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _breathingAnimation = Tween<double>(begin: 1.0, end: 0.38).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaskController>();
    final isConnected = controller.isConnected;
    final isRunning = controller.isRunning;

    // 工作状态下驱动平滑呼吸光晕，非运行状态下平缓归位
    if (isRunning) {
      if (!_breathingController.isAnimating) {
        _breathingController.repeat(reverse: true);
      }
    } else {
      if (_breathingController.isAnimating) {
        _breathingController.stop();
        _breathingController.value = 0.0;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title & Optional Combination Badge (Figma 0:810)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('modeSelection'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Central Circular Mode Selector (Figma 0:810 / 18:591 - Spanning edge-to-edge)
          Center(
            child: SizedBox(
              width: 328,
              height: 268,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Faint Ring (Figma 0:863, diameter 244)
                  Container(
                    width: 244,
                    height: 244,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.dialOrbit,
                        width: 1.5,
                      ),
                    ),
                  ),

                  // 6 Mode Nodes positioned around orbit ring
                  ...MaskModeType.values.map((mode) {
                    final isSelected = !controller.isCombinationActive && controller.selectedMode == mode;
                    return _buildModeNode(
                      context: context,
                      mode: mode,
                      isSelected: isSelected,
                      isRunning: isRunning,
                      onTap: () => controller.setMode(mode),
                    );
                  }),

                  // Center Start / Pause Button surrounded by Celestial Orbital Rings
                  CelestialOrbitalRing(
                    isRunning: isRunning,
                    size: 146,
                    child: _buildCenterActionButton(
                      context: context,
                      isRunning: isRunning,
                      isConnected: isConnected,
                      onTap: () {
                        if (!isConnected) {
                          AppToast.showGoldenToast(
                            context,
                            context.tr('deviceNotConnected'),
                          );
                          return;
                        }
                        if (controller.selectedMode == null && !controller.isCombinationActive) {
                          AppToast.showGoldenToast(
                            context,
                            context.tr('pleaseSelectMode'),
                          );
                          return;
                        }
                        controller.togglePower();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Row: save & Combination (Compact Capsule Pills with comfortable clearance)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save Button (Figma 0:37 编组 13备份 - 紧凑胶囊形态)
                InkWell(
                  onTap: widget.onSaveTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.capsuleBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.capsuleBorder, width: 0.8),
                    ),
                    child: Text(
                      context.tr('save'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                // Combination / Multi-Therapy Button (对齐6个标准模式的高级流金微透与光晕风格)
                InkWell(
                  onTap: widget.onCombinationTap,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      final double breath =
                          (isRunning && controller.isCombinationActive) ? _breathingAnimation.value : 1.0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: controller.isCombinationActive
                              ? AppColors.primary.withValues(alpha: 0.16 * breath)
                              : AppColors.capsuleBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: controller.isCombinationActive
                                ? AppColors.primary
                                : AppColors.capsuleBorder,
                            width: controller.isCombinationActive ? 1.0 : 0.8,
                          ),
                          boxShadow: controller.isCombinationActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: (isRunning ? 0.45 : 0.22) * breath),
                                    blurRadius: (isRunning ? 14 : 8) * breath,
                                    spreadRadius: (isRunning ? 2.0 : 1.0) * breath,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          context.tr('combination'),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: controller.isCombinationActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: controller.isCombinationActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeNode({
    required BuildContext context,
    required MaskModeType mode,
    required bool isSelected,
    required bool isRunning,
    required VoidCallback onTap,
  }) {
    // Exact Figma angles for all 6 modes
    final double angleInDegrees = switch (mode) {
      MaskModeType.rejuvenating => -90.0, // Top
      MaskModeType.firming => -30.0, // Top Right
      MaskModeType.lifting => 30.0, // Bottom Right
      MaskModeType.intensiveCare => 90.0, // Bottom
      MaskModeType.revitalizing => 150.0, // Bottom Left
      MaskModeType.plumping => 210.0, // Top Left
    };

    // Radius tuned to 118 to span gracefully across enlarged card
    const double radius = 118.0;
    final double angleInRadians = angleInDegrees * (math.pi / 180.0);
    final double x = radius * math.cos(angleInRadians);
    final double y = radius * math.sin(angleInRadians);

    final nodeColor = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Transform.translate(
      offset: Offset(x, y),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    final double breath =
                        (isRunning && isSelected) ? _breathingAnimation.value : 1.0;
                    return Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.18 * breath)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: (isRunning ? 0.50 : 0.25) * breath),
                                  blurRadius: (isRunning ? 16 : 10) * breath,
                                  spreadRadius: (isRunning ? 3.0 : 1.5) * breath,
                                ),
                              ]
                            : null,
                      ),
                      child: Opacity(
                        opacity: (isSelected && isRunning) ? (0.35 + 0.65 * breath) : 1.0,
                        child: BeautyHubIcon(
                          mode: mode,
                          color: nodeColor,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(mode.l10nKey),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: nodeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterActionButton({
    required BuildContext context,
    required bool isRunning,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: 98,
        height: 98,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isRunning ? const Color(0x66E5A95C) : const Color(0x22FFFFFF),
            width: 3.0,
          ),
          gradient: isRunning ? AppColors.primaryGradient : AppColors.inactiveGradient,
          boxShadow: [
            if (isRunning)
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
            Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              isRunning ? context.tr('pause') : context.tr('start'),
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
