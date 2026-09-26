import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/mask_mode.dart';
import '../../providers/mask_controller.dart';
import 'beauty_hub_icons.dart';

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
    // 呼吸光晕动画：周期 2.8 秒，平滑往复，Opacity 限制在 1.0 到 0.7 之间
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _breathingAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
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
    final currentMode = controller.currentMode;
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title & Optional Combination Badge (Figma 0:810)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('treatmentArea'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (controller.isCombinationActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${context.tr('combination')} ${controller.combinationCurrentStage + 1}/6',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Central Circular Mode Selector (Figma 0:810 / 18:591 - Spanning edge-to-edge)
          Center(
            child: SizedBox(
              width: 318,
              height: 256,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Faint Ring (Figma 0:863, diameter 240)
                  Container(
                    width: 236,
                    height: 236,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF2EEE9),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // 6 Mode Nodes positioned around orbit ring
                  ...MaskModeType.values.map((mode) {
                    return _buildModeNode(
                      context: context,
                      mode: mode,
                      isSelected: currentMode == mode,
                      isRunning: isRunning,
                      onTap: () => controller.setMode(mode),
                    );
                  }),

                  // Center Start / Pause Button (98x98)
                  _buildCenterActionButton(
                    context: context,
                    isRunning: isRunning,
                    isConnected: isConnected,
                    onTap: () {
                      if (!isConnected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('disconnected')),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      controller.togglePower();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Bottom Action Row (save & Combination) (Figma 0:849 & 0:830)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save Button (Figma 0:849)
                InkWell(
                  onTap: widget.onSaveTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bookmark_outline_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('save'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Combination Button (Figma 0:830)
                InkWell(
                  onTap: widget.onCombinationTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.layers_outlined,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('combination'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
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

    // Radius tuned to 114 to span gracefully across card
    const double radius = 114.0;
    final double angleInRadians = angleInDegrees * (math.pi / 180.0);
    final double x = radius * math.cos(angleInRadians);
    final double y = radius * math.sin(angleInRadians);

    final nodeColor = isSelected ? AppColors.primary : AppColors.textPrimary;

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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12 * breath)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: (isSelected && isRunning)
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25 * breath),
                                  blurRadius: 8 * breath,
                                  spreadRadius: 1.5 * breath,
                                ),
                              ]
                            : null,
                      ),
                      child: Opacity(
                        opacity: (isSelected && isRunning) ? breath : 1.0,
                        child: BeautyHubIcon(
                          modeId: mode.id,
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
