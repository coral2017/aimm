import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SkinWaterBar extends StatefulWidget {
  final String label;
  final double progress; // 0.0 ~ 1.0
  final bool isAnimating; // 是否处于运行中，驱动液面微波浪
  final double width;
  final double height;

  const SkinWaterBar({
    super.key,
    required this.label,
    required this.progress,
    this.isAnimating = false,
    this.width = 18.0,
    this.height = 80.0,
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
      duration: const Duration(milliseconds: 2500),
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
        // 柱状胶囊容器 (Figma 18px x 80px, 完全圆角 9px)
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.capsuleBackground, // Figma 0xFFF0EEE9 底槽色
            borderRadius: BorderRadius.circular(widget.width / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.width / 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: widget.progress.clamp(0.0, 1.0),
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              builder: (context, animatedValue, child) {
                return AnimatedBuilder(
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
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 底部指标文字 (对齐 Figma 规范，统一优雅呈现)
        SizedBox(
          width: 76,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Roboto',
              color: AppColors.textPrimary,
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
          Color(0xFFA6855B), // 顶部温暖明亮
          Color(0xFF8B683F), // 底部沉稳醇厚
        ],
      ).createShader(Rect.fromLTWH(0, topY, size.width, fillHeight));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, topY);

    if (isAnimating && progress > 0.03 && progress < 0.98) {
      // 绘制液面动态正弦微波纹 (振幅 1.2dp，细腻活性)
      for (double x = 0; x <= size.width; x += 1.0) {
        final y = topY + sin((x / size.width) * 2 * pi + wavePhase) * 1.2;
        path.lineTo(x, y);
      }
    } else {
      path.lineTo(size.width, topY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterLiquidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.isAnimating != isAnimating;
  }
}
