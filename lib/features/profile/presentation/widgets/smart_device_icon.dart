import 'package:flutter/material.dart';

/// Vector Smart Device Icon (reconstructed 1:1 from device.svg)
/// Represents smart BLE hardware device with broadcast waves and base stand.
class SmartDeviceIcon extends StatelessWidget {
  final Color color;
  final double size;

  const SmartDeviceIcon({
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
        painter: _SmartDevicePainter(color: color),
      ),
    );
  }
}

class _SmartDevicePainter extends CustomPainter {
  final Color color;

  _SmartDevicePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 16.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Inner wireless signal arc
    path.moveTo(4.6540, 5.8368);
    path.cubicTo(4.5205, 5.8368, 4.3781, 5.7923, 4.2624, 5.7124);
    path.cubicTo(3.9510, 5.4903, 3.8798, 5.0727, 4.1023, 4.7618);
    path.cubicTo(5.0010, 3.4825, 6.4604, 2.7185, 8.0177, 2.7185);
    path.cubicTo(9.5749, 2.7185, 11.0432, 3.4825, 11.9331, 4.7618);
    path.cubicTo(12.1555, 5.0727, 12.0665, 5.4992, 11.7729, 5.7124);
    path.cubicTo(11.4614, 5.9345, 11.0343, 5.8456, 10.8207, 5.5525);
    path.cubicTo(10.1800, 4.6374, 9.1389, 4.0955, 8.0266, 4.0955);
    path.cubicTo(6.9142, 4.0955, 5.8731, 4.6374, 5.2324, 5.5525);
    path.cubicTo(5.0900, 5.7390, 4.8765, 5.8368, 4.6540, 5.8368);
    path.close();

    // 2. Outer wireless signal arc
    path.moveTo(13.6416, 4.3354);
    path.cubicTo(13.4191, 4.3354, 13.2056, 4.2288, 13.0810, 4.0333);
    path.cubicTo(11.9331, 2.3542, 10.0377, 1.3504, 8.0088, 1.3504);
    path.cubicTo(5.9799, 1.3504, 4.0845, 2.3631, 2.9365, 4.0333);
    path.cubicTo(2.7141, 4.3443, 2.2958, 4.4242, 1.9933, 4.2110);
    path.cubicTo(1.6818, 3.9889, 1.6018, 3.5713, 1.8153, 3.2693);
    path.cubicTo(3.2213, 1.2260, 5.5438, 0.0000, 8.0088, 0.0000);
    path.cubicTo(10.4737, 0.0000, 12.8140, 1.2260, 14.2022, 3.2693);
    path.cubicTo(14.4247, 3.5802, 14.3357, 4.0067, 14.0242, 4.2110);
    path.cubicTo(13.8997, 4.2909, 13.7662, 4.3354, 13.6416, 4.3354);
    path.close();

    // 3. Hardware device outer body + stand legs
    path.moveTo(12.0132, 6.8051);
    path.lineTo(4.0044, 6.8051);
    path.cubicTo(1.8064, 6.8051, 0.0000, 8.5997, 0.0000, 10.8029);
    path.cubicTo(0.0000, 12.6863, 1.3170, 14.2765, 3.0789, 14.6941);
    path.lineTo(2.8387, 15.0050);
    path.cubicTo(2.6340, 15.2804, 2.6874, 15.6713, 2.9543, 15.8756);
    path.cubicTo(3.0700, 15.9645, 3.2035, 16.0000, 3.3281, 16.0000);
    path.cubicTo(3.5150, 16.0000, 3.7018, 15.9112, 3.8264, 15.7512);
    path.lineTo(4.5561, 14.7918);
    path.lineTo(11.4436, 14.7918);
    path.lineTo(12.1733, 15.7512);
    path.cubicTo(12.2979, 15.9112, 12.4848, 16.0000, 12.6717, 16.0000);
    path.cubicTo(12.8051, 16.0000, 12.9386, 15.9556, 13.0454, 15.8756);
    path.cubicTo(13.3213, 15.6713, 13.3746, 15.2804, 13.1611, 15.0050);
    path.lineTo(12.9208, 14.6941);
    path.cubicTo(14.6827, 14.2765, 15.9999, 12.6863, 15.9999, 10.8029);
    path.cubicTo(16.0175, 8.5997, 14.2200, 6.8051, 12.0132, 6.8051);
    path.close();

    // 4. Inner body cutout (punches out screen hole)
    path.moveTo(12.0132, 13.5569);
    path.lineTo(4.0044, 13.5569);
    path.cubicTo(2.4827, 13.5569, 1.2458, 12.3220, 1.2458, 10.8029);
    path.cubicTo(1.2458, 9.2837, 2.4827, 8.0489, 4.0044, 8.0489);
    path.lineTo(12.0132, 8.0489);
    path.cubicTo(13.5348, 8.0489, 14.7717, 9.2837, 14.7717, 10.8029);
    path.cubicTo(14.7717, 12.3220, 13.5348, 13.5569, 12.0132, 13.5569);
    path.close();

    // 5. Center status slot pill (filled inside the cutout)
    path.moveTo(12.2890, 11.4248);
    path.lineTo(3.7285, 11.4248);
    path.cubicTo(3.3815, 11.4248, 3.1056, 11.1494, 3.1056, 10.8029);
    path.cubicTo(3.1056, 10.4564, 3.3815, 10.1810, 3.7285, 10.1810);
    path.lineTo(12.2890, 10.1810);
    path.cubicTo(12.6361, 10.1810, 12.9119, 10.4564, 12.9119, 10.8029);
    path.cubicTo(12.9119, 11.1494, 12.6361, 11.4248, 12.2890, 11.4248);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmartDevicePainter oldDelegate) =>
      color != oldDelegate.color;
}
