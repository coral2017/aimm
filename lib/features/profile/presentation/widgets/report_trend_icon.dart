import 'package:flutter/material.dart';

/// Vector Report Trend Icon (reconstructed 1:1 from report.png)
/// Represents health report data trends with coordinate axes and upward arrow.
class ReportTrendIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ReportTrendIcon({
    super.key,
    required this.color,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ReportTrendPainter(color: color),
      ),
    );
  }
}

class _ReportTrendPainter extends CustomPainter {
  final Color color;

  _ReportTrendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. L-shaped Coordinate Axis (Left Y-axis & Bottom X-axis)
    final axisPath = Path()
      ..moveTo(w * 0.14, h * 0.14)
      ..lineTo(w * 0.14, h * 0.84)
      ..lineTo(w * 0.88, h * 0.84);
    canvas.drawPath(axisPath, strokePaint);

    // 2. Upward Trend Line (3 segments with slight dip before climb)
    final trendPath = Path()
      ..moveTo(w * 0.25, h * 0.64)
      ..lineTo(w * 0.43, h * 0.41)
      ..lineTo(w * 0.57, h * 0.54)
      ..lineTo(w * 0.84, h * 0.22);
    canvas.drawPath(trendPath, strokePaint);

    // 3. Arrow Tip Barbs at (0.84 * w, 0.22 * h)
    final arrowPath = Path()
      ..moveTo(w * 0.62, h * 0.22)
      ..lineTo(w * 0.84, h * 0.22)
      ..lineTo(w * 0.84, h * 0.44);
    canvas.drawPath(arrowPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ReportTrendPainter oldDelegate) =>
      color != oldDelegate.color;
}
