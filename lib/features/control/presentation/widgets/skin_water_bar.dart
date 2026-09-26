import 'dart:math';
import 'package:flutter/material.dart';

class SkinWaterBar extends StatefulWidget {
  final String label;
  final double progress; // 0.0 ~ 1.0
  final bool isHighlighted; // 是否为当前模式主推指标 (附带金光轮廓)
  final bool isAnimating; // 是否处于运行中，驱动液面微波浪
  final double width;
  final double height;

  const SkinWaterBar({
    super.key,
    required this.label,
    required this.progress,
    this.isHighlighted = false,
    this.isAnimating = false,
    this.width = 24.0,
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
        // 柱状容器 (Background trough + Border Glow)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFF3ECE4), // 背景底槽色
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isHighlighted
                  ? const Color(0xFFD4A373).withValues(alpha: 0.85)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: widget.isHighlighted
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.25),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.5),
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

        const SizedBox(height: 8),

        // 底部指标文字 (联动高亮深色与加粗)
        SizedBox(
          width: 76,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Roboto',
              color: widget.isHighlighted
                  ? const Color(0xFF7A583E)
                  : const Color(0xFF888888),
              fontWeight: widget.isHighlighted
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFE2C4A6), // 底部温润精油色
          Color(0xFFF2DFCE), // 顶部水光浅色
        ],
      ).createShader(Rect.fromLTWH(0, topY, size.width, fillHeight));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, topY);

    if (isAnimating && progress > 0.03 && progress < 0.98) {
      // 绘制液面动态正弦微波纹 (振幅 1.5dp)
      for (double x = 0; x <= size.width; x += 1.0) {
        final y = topY + sin((x / size.width) * 2 * pi + wavePhase) * 1.5;
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
