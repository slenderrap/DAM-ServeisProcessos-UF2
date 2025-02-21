import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CanvasPainter extends CustomPainter {
  final ui.Image layerImage;

  CanvasPainter(this.layerImage);

  @override
  void paint(Canvas canvas, Size size) {
    double imageWidth = layerImage.width.toDouble();
    double imageHeight = layerImage.height.toDouble();
    double availableWidth = size.width;
    double availableHeight = size.height;

    // Calcular el factor d'escala mantenint la proporció
    double scale = (availableWidth / imageWidth).clamp(0.0, 1.0);
    if (imageHeight * scale > availableHeight) {
      scale = (availableHeight / imageHeight).clamp(0.0, 1.0);
    }

    // Calcular la nova mida escalada
    double scaledWidth = imageWidth * scale;
    double scaledHeight = imageHeight * scale;

    // Calcular posició per centrar la imatge
    double dx = (availableWidth - scaledWidth) / 2;
    double dy = (availableHeight - scaledHeight) / 2;

    // Dibuixar la imatge centrada i escalada
    canvas.drawImageRect(
      layerImage,
      Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      Rect.fromLTWH(dx, dy, scaledWidth, scaledHeight),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.layerImage != layerImage;
  }
}
