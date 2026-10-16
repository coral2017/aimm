import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/mask_mode.dart';

class BeautyHubIcon extends StatelessWidget {
  final MaskModeType? mode;
  final int? modeId;
  final Color color;
  final double size;

  const BeautyHubIcon({
    super.key,
    this.mode,
    this.modeId,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMode = mode ??
        (modeId != null ? MaskModeType.fromId(modeId!) : MaskModeType.firming);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BeautyHubIconPainter(mode: effectiveMode, color: color),
      ),
    );
  }
}

class _BeautyHubIconPainter extends CustomPainter {
  final MaskModeType mode;
  final Color color;

  _BeautyHubIconPainter({required this.mode, required this.color});

  // Pre-compiled 1:1 exact vector path parsed directly from Figma (node 18:692)
  static final Path _revitalizingPath = _buildRevitalizingPath();

  static Path _buildRevitalizingPath() {
    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Eyes & mouth (subpixel curves)
    const dEyesAndMouth =
        "M17.7427 9.77857C17.4807 9.77857 17.2545 9.58231 17.2231 9.31579"
        "C17.1631 8.81945 16.8604 7.73218 16.3504 7.73216C15.8442 7.73216"
        " 15.5727 8.81106 15.5263 9.30347C15.499 9.59168 15.2471 9.80191"
        " 14.9553 9.77618C14.667 9.7492 14.4556 9.49347 14.4826 9.20543"
        "C14.5705 8.26889 15.0629 6.68395 16.3501 6.68395C17.629 6.68395"
        " 18.1549 8.26154 18.264 9.19342C18.2977 9.48086 18.092 9.74112"
        " 17.8043 9.77491C17.7836 9.77755 17.7631 9.77857 17.7427 9.77857ZM9.2369"
        " 7.73247C9.74689 7.73247 10.0496 8.82001 10.1096 9.31632C10.141"
        " 9.58255 10.3672 9.77857 10.6292 9.77857C10.6494 9.77857 10.6701"
        " 9.77755 10.6908 9.77518C10.9783 9.74139 11.184 9.48113 11.1505"
        " 9.19369C11.0414 8.26181 10.5155 6.68426 9.23692 6.68426C7.94948"
        " 6.68426 7.4571 8.26916 7.3693 9.20577C7.34202 9.49376 7.55375"
        " 9.74952 7.84203 9.77651C8.13002 9.8035 8.38549 9.59201 8.4128"
        " 9.30373C8.45913 8.81133 8.73094 7.73247 9.2369 7.73247ZM12.4307"
        " 16.7784C15.8727 16.7784 16.1586 14.2849 16.1615 14.2593C16.1896"
        " 13.9739 15.9827 13.722 15.6976 13.6903C15.4116 13.6599 15.1541"
        " 13.8645 15.119 14.1499C15.111 14.2143 14.8936 15.7299 12.4306"
        " 15.7299C9.978 15.7299 9.75239 14.2275 9.74269 14.151C9.7115"
        " 13.8655 9.45523 13.6573 9.1701 13.6863C8.88211 13.7149 8.67166"
        " 13.9712 8.69999 14.2594C8.70234 14.2843 8.98825 16.7784 12.4307 16.7784Z";

    // 2. Head perimeter arc
    const dHead =
        "M5.6345 15.6973C4.60381 14.316 3.99293 12.6058 3.99293 10.7557"
        "C3.99293 6.18105 7.72513 2.45934 12.313 2.45934C16.9008 2.45934"
        " 20.633 6.18103 20.633 10.7557C20.633 12.6058 20.0221 14.316"
        " 18.9915 15.6973C19.3806 15.7168 19.7483 15.8137 20.0803 15.9746"
        "C21.0906 14.4835 21.6809 12.6872 21.6809 10.7557C21.6809 5.60323"
        " 17.4784 1.41114 12.3127 1.41114C7.14711 1.41114 2.94474 5.603"
        " 2.94474 10.7555C2.94474 12.6869 3.53516 14.4833 4.5454 15.9744"
        "C4.87766 15.8137 5.2453 15.7165 5.6345 15.6973Z";

    // 3. Chin and the two hollow round hands
    const dChinAndHands =
        "M18.8498 15.6966C17.4083 15.6966 16.2158 16.7772 16.0413 18.169"
        "L16.0428 18.1682C16.0284 18.2841 16.0184 18.4015 16.0184 18.5215"
        "C16.0184 18.4021 16.0268 18.2846 16.0412 18.169C14.9189 18.7328"
        " 13.6529 19.0522 12.3127 19.0522C10.9726 19.0522 9.70666 18.7328"
        " 8.58435 18.169C8.59887 18.2846 8.6072 18.4021 8.6072 18.5215"
        "C8.6072 18.4017 8.59725 18.2844 8.5828 18.1682L8.58433 18.169"
        "C8.40978 16.7772 7.21726 15.6966 5.77593 15.6966C4.21487 15.6966"
        " 2.94466 16.9638 2.94466 18.5215C2.94466 20.0792 4.21485 21.3465"
        " 5.77593 21.3465C7.07065 21.3465 8.16457 20.4743 8.5004 19.2882"
        "L8.49946 19.2877C8.55034 19.107 8.58346 18.9217 8.59834 18.7345"
        "C8.58431 18.9219 8.55151 19.1073 8.50042 19.2881C9.66608 19.8084"
        " 10.9555 20.1001 12.3129 20.1001C13.6703 20.1001 14.9596 19.8084"
        " 16.1253 19.2882C16.4611 20.4744 17.555 21.3464 18.8498 21.3464"
        "C20.4109 21.3464 21.6811 20.0792 21.6811 18.5215C21.6811 16.9638"
        " 20.4109 15.6966 18.8498 15.6966ZM16.1253 19.2882L16.1264 19.2877"
        "C16.0762 19.1094 16.0421 18.9242 16.0273 18.7338C16.0412 18.9214"
        " 16.0741 19.1072 16.1253 19.2882ZM5.77597 20.2982C4.79272 20.2982"
        " 3.99293 19.5009 3.99293 18.5213C3.99293 17.5417 4.79272 16.7445"
        " 5.77597 16.7445C6.75922 16.7445 7.55899 17.542 7.55899 18.5215"
        "C7.55899 19.5011 6.75893 20.2982 5.77597 20.2982ZM17.0666 18.5213"
        "C17.0666 19.5009 17.8667 20.2982 18.8498 20.2982C19.8332 20.2982"
        " 20.633 19.5011 20.633 18.5215C20.633 17.542 19.8332 16.7445"
        " 18.8498 16.7445C17.8667 16.7445 17.0666 17.5417 17.0666 18.5213Z";

    _parseSvgPath(dEyesAndMouth, path);
    _parseSvgPath(dHead, path);
    _parseSvgPath(dChinAndHands, path);
    return path;
  }

  static void _parseSvgPath(String d, Path path) {
    final regex = RegExp(r'([a-zA-Z])|([+-]?(?:\d*\.\d+|\d+)(?:[eE][+-]?\d+)?)');
    final matches = regex.allMatches(d);
    String currentCmd = '';
    final args = <double>[];

    for (final m in matches) {
      final token = m.group(0)!;
      final isCmd = RegExp(r'^[a-zA-Z]$').hasMatch(token);

      if (isCmd) {
        currentCmd = token;
        if (currentCmd == 'Z' || currentCmd == 'z') {
          path.close();
        }
        args.clear();
      } else {
        args.add(double.parse(token));
        if (currentCmd == 'M' && args.length == 2) {
          path.moveTo(args[0], args[1]);
          currentCmd = 'L';
          args.clear();
        } else if (currentCmd == 'L' && args.length == 2) {
          path.lineTo(args[0], args[1]);
          args.clear();
        } else if (currentCmd == 'C' && args.length == 6) {
          path.cubicTo(args[0], args[1], args[2], args[3], args[4], args[5]);
          args.clear();
        }
      }
    }
  }

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

    switch (mode) {
      // 焕活 (Rejuvenating) - 6 small circles surrounding central ring
      case MaskModeType.rejuvenating:
        final r = w * 0.12;
        final orbitR = w * 0.32;
        for (int i = 0; i < 6; i++) {
          final angle = i * (math.pi / 3);
          final ox = cx + orbitR * math.cos(angle);
          final oy = cy + orbitR * math.sin(angle);
          canvas.drawCircle(Offset(ox, oy), r, paint);
        }
        break;

      // 紧致 (Firming) - Loop/dome with radiant downward rays
      case MaskModeType.firming:
        // Top loop
        canvas.drawCircle(Offset(cx, cy - h * 0.12), w * 0.22, paint);
        // Horizontal baseline
        canvas.drawLine(Offset(w * 0.2, cy + h * 0.15), Offset(w * 0.8, cy + h * 0.15), paint);
        // Downward radiant rays
        canvas.drawLine(Offset(w * 0.3, cy + h * 0.24), Offset(w * 0.25, cy + h * 0.42), paint);
        canvas.drawLine(Offset(cx, cy + h * 0.24), Offset(cx, cy + h * 0.44), paint);
        canvas.drawLine(Offset(w * 0.7, cy + h * 0.24), Offset(w * 0.75, cy + h * 0.42), paint);
        break;

      // 提拉 (Lifting) - 3 horizontal wavy lines
      case MaskModeType.lifting:
        for (int i = 0; i < 3; i++) {
          final yOffset = cy - h * 0.25 + i * (h * 0.25);
          final path = Path();
          path.moveTo(w * 0.15, yOffset);
          path.quadraticBezierTo(w * 0.35, yOffset - h * 0.1, w * 0.5, yOffset);
          path.quadraticBezierTo(w * 0.65, yOffset + h * 0.1, w * 0.85, yOffset);
          canvas.drawPath(path, paint);
        }
        break;

      // 瞬透 (Intensive Care) - Flexing bicep arm
      case MaskModeType.intensiveCare:
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

      // 活肌 (Revitalizing) - 1:1 Pixel-Perfect Figma vector path (Figma 18:692)
      case MaskModeType.revitalizing:
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.scale(w / 24.0, h / 24.0);
        canvas.drawPath(_revitalizingPath, fillPaint);
        canvas.restore();
        break;

      // 澎弹 (Plumping) - Mirror / droplet with stem
      case MaskModeType.plumping:
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
    }
  }

  @override
  bool shouldRepaint(covariant _BeautyHubIconPainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.color != color;
  }
}
