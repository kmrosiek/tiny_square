import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedBorderPainter extends CustomPainter {
  AnimatedBorderPainter({
    required this.progress,
    required this.color,
    required this.opacity,
    required this.borderRadius,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double opacity;
  final double borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity == 0) {
      return;
    }

    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Draw faint background border
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, backgroundPaint);

    // Draw animated segment
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    // Segment length (25% of perimeter)
    final segmentLength = pathLength * 0.25;
    final startDistance = (progress * pathLength) % pathLength;

    // Extract the segment
    final extractPath = pathMetrics.extractPath(startDistance, math.min(startDistance + segmentLength, pathLength));

    canvas.drawPath(extractPath, paint);

    // Handle wrap-around
    if (startDistance + segmentLength > pathLength) {
      final wrapPath = pathMetrics.extractPath(0, (startDistance + segmentLength) - pathLength);
      canvas.drawPath(wrapPath, paint);
    }
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
