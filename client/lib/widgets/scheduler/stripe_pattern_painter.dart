import 'dart:math';
import 'package:flutter/material.dart';

// Custom Painter to draw diagonal stripes
class StripePatternPainter extends CustomPainter {
  final double stripeWidth;
  final double gapWidth;
  final double rotateDegree;
  final Color stripeColor;
  final Color bgColor;

  StripePatternPainter({
    this.stripeWidth = 5.0,
    this.gapWidth = 5.0,
    this.rotateDegree = 45.0,
    this.stripeColor = Colors.grey,
    this.bgColor = Colors.transparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate joint size
    final double jointSize = stripeWidth + gapWidth;

    // Convert degree to radian
    final rotateRadian = pi / 180 * rotateDegree;

    // Calculate offsets
    final xOffset = jointSize / sin(rotateRadian);
    final yOffset = jointSize / sin(pi / 2 - rotateRadian);

    // Paint stripes
    final paint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stripeWidth;

    final path = Path();

    for (double x = -size.width; x < size.width * 2; x += xOffset) {
      path.moveTo(x, 0);
      path.lineTo(x + size.height / tan(rotateRadian), size.height);
    }

    // Draw stripes
    canvas.drawPath(path, paint);

    // Fill the background
    final backgroundPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
