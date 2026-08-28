import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/report_model.dart';

class RadarChartWidget extends StatelessWidget {
  final List<RadarDimension> dimensions;

  const RadarChartWidget({
    super.key,
    required this.dimensions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: CustomPaint(
        painter: _RadarChartPainter(
          dimensions: dimensions,
          context: context,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<RadarDimension> dimensions;
  final BuildContext context;

  _RadarChartPainter({
    required this.dimensions,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.32;
    final int sides = dimensions.length;

    if (sides < 3) return;

    // Paints
    final gridPaint = Paint()
      ..color = const Color(0xFFEAE6DE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final outerRingPaint = Paint()
      ..color = const Color(0xFFF2EFEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dataFillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final dataStrokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    // 1. Draw outer circle guides
    canvas.drawCircle(center, radius * 1.15, outerRingPaint);
    canvas.drawCircle(center, radius * 1.30, outerRingPaint);

    // 2. Draw 4 Concentric Polygon Grids (25%, 50%, 75%, 100%)
    for (int step = 1; step <= 4; step++) {
      final double r = radius * (step / 4.0);
      final gridPath = Path();
      for (int i = 0; i < sides; i++) {
        // Start from top (-90 degrees)
        final double angle = -math.pi / 2 + (2 * math.pi / sides) * i;
        final double x = center.dx + r * math.cos(angle);
        final double y = center.dy + r * math.sin(angle);
        if (i == 0) {
          gridPath.moveTo(x, y);
        } else {
          gridPath.lineTo(x, y);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    // 3. Draw Axis Lines from Center to Vertices
    for (int i = 0; i < sides; i++) {
      final double angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // 4. Compute Data Polygon Path
    final dataPath = Path();
    final List<Offset> dataPoints = [];

    for (int i = 0; i < sides; i++) {
      final double scoreFraction = (dimensions[i].score / 100.0).clamp(0.1, 1.0);
      final double r = radius * scoreFraction;
      final double angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      final point = Offset(x, y);
      dataPoints.add(point);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // 5. Draw Data Polygon Fill & Stroke
    canvas.drawPath(dataPath, dataFillPaint);
    canvas.drawPath(dataPath, dataStrokePaint);

    // 6. Draw Vertex Dots
    for (final pt in dataPoints) {
      canvas.drawCircle(pt, 3.5, dotPaint);
      canvas.drawCircle(pt, 1.5, Paint()..color = Colors.white);
    }

    // 7. Draw Labels & Scores
    for (int i = 0; i < sides; i++) {
      final dim = dimensions[i];
      final double angle = -math.pi / 2 + (2 * math.pi / sides) * i;
      final double labelDistance = radius * 1.38;
      final double x = center.dx + labelDistance * math.cos(angle);
      final double y = center.dy + labelDistance * math.sin(angle);

      final labelText = context.tr(dim.labelKey);

      final textSpan = TextSpan(
        children: [
          TextSpan(
            text: '$labelText\n',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          TextSpan(
            text: '${dim.score}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}
