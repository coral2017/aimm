import 'package:flutter/material.dart';

/// Exclusive Mask + BLE Smart Hardware icon for Device Management
class MaskBleHardwareIcon extends StatelessWidget {
  final Color color;
  final double size;

  const MaskBleHardwareIcon({
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
        painter: _MaskBleHardwarePainter(color: color),
      ),
    );
  }
}

class _MaskBleHardwarePainter extends CustomPainter {
  final Color color;

  _MaskBleHardwarePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Mask Contour Path (Ergonomic beauty mask contour)
    final maskPath = Path();
    // Forehead curve
    maskPath.moveTo(4.8 * scale, 9.5 * scale);
    maskPath.cubicTo(
      5.5 * scale, 5.0 * scale,
      14.5 * scale, 5.0 * scale,
      15.2 * scale, 9.5 * scale,
    );
    // Right cheek to chin
    maskPath.cubicTo(
      15.6 * scale, 14.8 * scale,
      13.0 * scale, 19.8 * scale,
      10.0 * scale, 20.0 * scale,
    );
    // Left cheek from chin back to forehead
    maskPath.cubicTo(
      7.0 * scale, 19.8 * scale,
      4.4 * scale, 14.8 * scale,
      4.8 * scale, 9.5 * scale,
    );
    canvas.drawPath(maskPath, strokePaint);

    // 2. Eyes: Serene subtle curved arcs
    final leftEyePath = Path();
    leftEyePath.moveTo(6.5 * scale, 10.5 * scale);
    leftEyePath.quadraticBezierTo(7.7 * scale, 11.8 * scale, 8.9 * scale, 10.5 * scale);
    canvas.drawPath(leftEyePath, strokePaint);

    final rightEyePath = Path();
    rightEyePath.moveTo(11.1 * scale, 10.5 * scale);
    rightEyePath.quadraticBezierTo(12.3 * scale, 11.8 * scale, 13.5 * scale, 10.5 * scale);
    canvas.drawPath(rightEyePath, strokePaint);

    // 3. Mouth: Small subtle calm arc
    final mouthPath = Path();
    mouthPath.moveTo(8.8 * scale, 15.6 * scale);
    mouthPath.quadraticBezierTo(10.0 * scale, 16.5 * scale, 11.2 * scale, 15.6 * scale);
    canvas.drawPath(mouthPath, strokePaint);

    // 4. BLE Wireless Signal Waves (Top-Right emitting outward)
    // Inner wave
    final innerWave = Path();
    innerWave.addArc(
      Rect.fromCircle(center: Offset(13.5 * scale, 8.5 * scale), radius: 5.5 * scale),
      -1.35,
      1.15,
    );
    canvas.drawPath(innerWave, strokePaint);

    // Outer wave
    final outerWave = Path();
    outerWave.addArc(
      Rect.fromCircle(center: Offset(13.5 * scale, 8.5 * scale), radius: 8.5 * scale),
      -1.35,
      1.15,
    );
    canvas.drawPath(outerWave, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MaskBleHardwarePainter oldDelegate) =>
      color != oldDelegate.color;
}
