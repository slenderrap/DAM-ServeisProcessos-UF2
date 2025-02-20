import 'package:flutter/rendering.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter();

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
