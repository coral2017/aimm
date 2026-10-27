import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SkinWaterBar extends StatefulWidget {
  final String label;
  final double progress; // 0.0 ~ 1.0
  final bool isHighlighted; // 是否为主攻指标高亮 (Border Glow)
  final bool isAnimating; // 是否处于运行中，驱动液面波浪动效
  final double width;
  final double height;

  const SkinWaterBar({
    super.key,
    required this.label,
    required this.progress,
    this.isHighlighted = false,
    this.isAnimating = false,
    this.width = 20.0,
    this.height = 68.0,
  });

  @override
  State<SkinWaterBar> createState() => _SkinWaterBarState();
}

class _SkinWaterBarState extends State<SkinWaterBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.isAnimating) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(SkinWaterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!widget.isAnimating && _waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 柱状指示槽 (对齐 Figma 设计稿：极淡优雅的细边框 + 金色液体柔和漫反射投影阴影)
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0.0,
            end: widget.progress.clamp(0.0, 1.0),
          ),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
          builder: (context, animatedValue, child) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // 1. 设计稿规范：金黄色液体柔和漫反射投影阴影（静态常驻、温暖通透，随液面高度自然呈现）
                  if (animatedValue > 0.02)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: (widget.height * animatedValue).clamp(4.0, widget.height),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE5A95C).withValues(alpha: 0.33),
                              blurRadius: 5,
                              spreadRadius: 0.4,
                            ),
                            BoxShadow(
                              color: const Color(0xFFC8832E).withValues(alpha: 0.20),
                              blurRadius: 9,
                              spreadRadius: 0.6,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 2. 试管槽主体（深色槽体底色 + 极淡精致的浅白微边框 + 微深色下凹阴影）
                  Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: AppColors.waterBarTrack,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 0.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.4),
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _WaterLiquidPainter(
                              progress: animatedValue,
                              wavePhase: _waveController.value * 2 * pi,
                              isAnimating: widget.isAnimating,
                            ),
                            size: Size(widget.width, widget.height),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // 底部指标文字 (四列统一样式，保持设计稿的秩序感与高级感)
        SizedBox(
          width: 76,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Roboto',
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaterLiquidPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final bool isAnimating;

  _WaterLiquidPainter({
    required this.progress,
    required this.wavePhase,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    final fillHeight = size.height * progress;
    final topY = size.height - fillHeight;

    // 对齐 Figma 原设计稿的经典品牌金棕色/香槟渐变
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryLight,
          AppColors.primaryDark,
        ],
      ).createShader(Rect.fromLTWH(0, topY, size.width, fillHeight));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, topY);

    if (isAnimating && progress > 0.02 && progress < 0.98) {
      // 细腻微澜波纹：增大波纹密度(约1.75个波长周期)，降低振幅(0.75dp)，呈现精华凝露的精致水光微漾
      for (double x = 0; x <= size.width; x += 0.8) {
        final y = topY + sin((x / size.width) * 3.5 * pi + wavePhase) * 0.75;
        path.lineTo(x, y);
      }
    } else {
      path.lineTo(size.width, topY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // 顶部液面晶莹高光线 (Shimmer Highlight)
    if (progress > 0.02 && progress < 0.99) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(1, topY + 0.4),
        Offset(size.width - 1, topY + 0.4),
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaterLiquidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.isAnimating != isAnimating;
  }
}
