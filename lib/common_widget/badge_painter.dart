import 'dart:math';
import 'package:flutter/material.dart';

class BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D4A5C)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    const teeth = 12;
    const outerRadius = 50.0;
    const innerRadius = 42.0;

    for (int i = 0; i < teeth * 2; i++) {
      final angle = (i * 180 / teeth) * pi / 180;
      final r = i % 2 == 0 ? outerRadius : innerRadius;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
