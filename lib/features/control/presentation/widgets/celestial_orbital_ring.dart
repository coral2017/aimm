import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 酷炫流光星环组件 (Celestial Orbital Ring)
/// 围绕开始/暂停按钮旋转的动态金光光轨与微澜星环，
/// 待机状态下以 18 秒/圈悠然自转，开机工作状态下以 4 秒/圈加速流动并呼吸律动。
class CelestialOrbitalRing extends StatefulWidget {
  final bool isRunning;
  final Widget child;
  final double size;

  const CelestialOrbitalRing({
    super.key,
    required this.isRunning,
    required this.child,
    this.size = 146.0,
  });

  @override
  State<CelestialOrbitalRing> createState() => _CelestialOrbitalRingState();
}

class _CelestialOrbitalRingState extends State<CelestialOrbitalRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    final duration = widget.isRunning
        ? const Duration(milliseconds: 4000)
        : const Duration(milliseconds: 18000);

    _rotationController = AnimationController(
      vsync: this,
      duration: duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(CelestialOrbitalRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) {
      final double currentValue = _rotationController.value;
      _rotationController.duration = widget.isRunning
          ? const Duration(milliseconds: 4000)
          : const Duration(milliseconds: 18000);
      _rotationController.forward(from: currentValue);
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 动态流光星环绘制层
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, _) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _OrbitalRingPainter(
                  progress: _rotationController.value,
                  isRunning: widget.isRunning,
                ),
              );
            },
          ),

          // 中心被环绕的按钮
          widget.child,
        ],
      ),
    );
  }
}

class _OrbitalRingPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  _OrbitalRingPainter({
    required this.progress,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    // 两个同心轨道半径 (内轨半径 ~57, 外轨半径 ~66)
    final double rInner = baseRadius * 0.77;
    final double rOuter = baseRadius * 0.90;

    // 1. 绘制静谧底轨 (极细半透光轨)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.primary.withValues(alpha: isRunning ? 0.28 : 0.16);

    canvas.drawCircle(center, rInner, trackPaint);

    final outerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = AppColors.primary.withValues(alpha: isRunning ? 0.20 : 0.10);

    canvas.drawCircle(center, rOuter, outerTrackPaint);

    // 2. 绘制环绕旋转的流金光弧
    final rotationAngle = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    // --- 主光弧 1 (在内轨运行，弧长约 110度) ---
    _drawGlowingArc(
      canvas: canvas,
      radius: rInner,
      startAngle: 0.0,
      sweepAngle: 1.9, // ~110度
      strokeWidth: isRunning ? 2.2 : 1.8,
      headGlowAlpha: isRunning ? 0.95 : 0.75,
      isPrimary: true,
    );

    // --- 次光弧 2 (在外轨对角运行，弧长约 85度) ---
    _drawGlowingArc(
      canvas: canvas,
      radius: rOuter,
      startAngle: math.pi + 0.3,
      sweepAngle: 1.5, // ~85度
      strokeWidth: isRunning ? 1.8 : 1.4,
      headGlowAlpha: isRunning ? 0.80 : 0.60,
      isPrimary: false,
    );

    // --- 微弱伴随光弧 3 (增加层次感，弧长约 45度) ---
    _drawGlowingArc(
      canvas: canvas,
      radius: (rInner + rOuter) / 2,
      startAngle: 2.4,
      sweepAngle: 0.8,
      strokeWidth: 1.2,
      headGlowAlpha: isRunning ? 0.50 : 0.30,
      isPrimary: false,
    );

    canvas.restore();
  }

  void _drawGlowingArc({
    required Canvas canvas,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required double strokeWidth,
    required double headGlowAlpha,
    required bool isPrimary,
  }) {
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // 光弧本体带尾迹衰减渐变
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primaryLight.withValues(alpha: headGlowAlpha * 0.85),
          const Color(0xFFFFF7E6).withValues(alpha: headGlowAlpha),
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // 光弧发光羽化层 (Glow Bloom)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5)
      ..color = AppColors.primary.withValues(alpha: headGlowAlpha * 0.45);

    canvas.drawArc(rect, startAngle + sweepAngle * 0.3, sweepAngle * 0.7, false, glowPaint);

    // 头部高能流星璀璨光点
    final headAngle = startAngle + sweepAngle;
    final headX = radius * math.cos(headAngle);
    final headY = radius * math.sin(headAngle);

    // 外发光星晕
    final headGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
      ..color = AppColors.primaryLight.withValues(alpha: headGlowAlpha * 0.6);
    canvas.drawCircle(Offset(headX, headY), 3.0, headGlowPaint);

    // 核心微白高亮点
    final headPointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFF9EC).withValues(alpha: headGlowAlpha);
    canvas.drawCircle(Offset(headX, headY), 1.5, headPointPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isRunning != isRunning;
  }
}
