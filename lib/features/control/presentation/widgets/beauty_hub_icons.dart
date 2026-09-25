import 'dart:math' as math;
import 'package:flutter/material.dart';

class BeautyHubIcon extends StatelessWidget {
  final int modeId;
  final Color color;
  final double size;

  const BeautyHubIcon({
    super.key,
    required this.modeId,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BeautyHubIconPainter(modeId: modeId, color: color),
      ),
    );
  }
}

class _BeautyHubIconPainter extends CustomPainter {
  final int modeId;
  final Color color;

  _BeautyHubIconPainter({required this.modeId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    switch (modeId) {
      // 0: Rejuvenating (活肤焕颜) - 6 small circles surrounding central ring
      case 0:
        final r = w * 0.12;
        final orbitR = w * 0.32;
        for (int i = 0; i < 6; i++) {
          final angle = i * (math.pi / 3);
          final ox = cx + orbitR * math.cos(angle);
          final oy = cy + orbitR * math.sin(angle);
          canvas.drawCircle(Offset(ox, oy), r, paint);
        }
        break;

      // 1: Firming (紧致抗皱) - Loop/dome with radiant downward rays
      case 1:
        // Top loop
        canvas.drawCircle(Offset(cx, cy - h * 0.12), w * 0.22, paint);
        // Horizontal baseline
        canvas.drawLine(Offset(w * 0.2, cy + h * 0.15), Offset(w * 0.8, cy + h * 0.15), paint);
        // Downward radiant rays
        canvas.drawLine(Offset(w * 0.3, cy + h * 0.24), Offset(w * 0.25, cy + h * 0.42), paint);
        canvas.drawLine(Offset(cx, cy + h * 0.24), Offset(cx, cy + h * 0.44), paint);
        canvas.drawLine(Offset(w * 0.7, cy + h * 0.24), Offset(w * 0.75, cy + h * 0.42), paint);
        break;

      // 2: Lifting (提拉塑型) - 3 horizontal wavy lines
      case 2:
        for (int i = 0; i < 3; i++) {
          final yOffset = cy - h * 0.25 + i * (h * 0.25);
          final path = Path();
          path.moveTo(w * 0.15, yOffset);
          path.quadraticBezierTo(w * 0.35, yOffset - h * 0.1, w * 0.5, yOffset);
          path.quadraticBezierTo(w * 0.65, yOffset + h * 0.1, w * 0.85, yOffset);
          canvas.drawPath(path, paint);
        }
        break;

      // 3: Intensive Care (深度修护) - Flexing bicep arm
      case 3:
        final path = Path();
        // Bicep curve
        path.moveTo(w * 0.25, cy + h * 0.3);
        path.lineTo(w * 0.25, cy - h * 0.05);
        path.quadraticBezierTo(w * 0.35, cy - h * 0.35, w * 0.55, cy - h * 0.35);
        path.quadraticBezierTo(w * 0.75, cy - h * 0.3, w * 0.75, cy - h * 0.05);
        path.quadraticBezierTo(w * 0.85, cy + h * 0.05, w * 0.75, cy + h * 0.25);
        path.lineTo(w * 0.6, cy + h * 0.3);
        path.quadraticBezierTo(w * 0.45, cy + h * 0.1, w * 0.45, cy + h * 0.3);
        path.close();
        canvas.drawPath(path, paint);
        break;

      // 4: Revitalizing (舒缓修护) - Cute smiling face with two hands (Figma 18:692)
      case 4:
        final faceCenter = Offset(cx, cy - h * 0.06);
        final faceRadius = w * 0.38;

        // Head outer circle arc (leaving gap at bottom for hands)
        canvas.drawArc(
          Rect.fromCircle(center: faceCenter, radius: faceRadius),
          math.pi * 0.18,
          math.pi * 1.64,
          false,
          paint,
        );

        // Eyes (two cute smiling arches ^ ^)
        final leftEye = Path();
        leftEye.moveTo(cx - w * 0.20, cy - h * 0.09);
        leftEye.quadraticBezierTo(cx - w * 0.13, cy - h * 0.20, cx - w * 0.06, cy - h * 0.09);
        canvas.drawPath(leftEye, paint);

        final rightEye = Path();
        rightEye.moveTo(cx + w * 0.06, cy - h * 0.09);
        rightEye.quadraticBezierTo(cx + w * 0.13, cy - h * 0.20, cx + w * 0.20, cy - h * 0.09);
        canvas.drawPath(rightEye, paint);

        // Smile mouth curve
        final smilePath = Path();
        smilePath.moveTo(cx - w * 0.14, cy + h * 0.06);
        smilePath.quadraticBezierTo(cx, cy + h * 0.19, cx + w * 0.14, cy + h * 0.06);
        canvas.drawPath(smilePath, paint);

        // Two little cute round hands resting on cheeks/chin
        final handRadius = w * 0.09;
        canvas.drawCircle(Offset(cx - w * 0.27, cy + h * 0.27), handRadius, paint);
        canvas.drawCircle(Offset(cx + w * 0.27, cy + h * 0.27), handRadius, paint);

        // Bottom chin curve between hands
        final chinPath = Path();
        chinPath.moveTo(cx - w * 0.14, cy + h * 0.26);
        chinPath.quadraticBezierTo(cx, cy + h * 0.32, cx + w * 0.14, cy + h * 0.26);
        canvas.drawPath(chinPath, paint);
        break;

      // 5: Plumping (水光盈润) - Mirror / droplet with stem
      case 5:
        // Top oval/circle
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy - h * 0.1), width: w * 0.5, height: h * 0.6),
          paint,
        );
        // Inner reflection line
        final refPath = Path();
        refPath.moveTo(cx - w * 0.05, cy - h * 0.25);
        refPath.lineTo(cx + w * 0.1, cy + h * 0.05);
        canvas.drawPath(refPath, paint);
        // Bottom stem
        canvas.drawLine(Offset(cx, cy + h * 0.2), Offset(cx, cy + h * 0.4), paint);
        break;

      default:
        canvas.drawCircle(Offset(cx, cy), w * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BeautyHubIconPainter oldDelegate) {
    return oldDelegate.modeId != modeId || oldDelegate.color != color;
  }
}
