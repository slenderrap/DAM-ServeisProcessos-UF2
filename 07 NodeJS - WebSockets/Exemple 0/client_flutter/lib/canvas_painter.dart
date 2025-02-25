import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'app_data.dart';

class CanvasPainter extends CustomPainter {
  final AppData appData;

  CanvasPainter(this.appData);

  @override
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Dibuixar fons blanc
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    var gameState = appData.gameState;
    if (gameState.isNotEmpty) {
      // Dibuixar objectes en negre
      if (gameState["objects"] != null) {
        for (var obj in gameState["objects"]) {
          paint.color = Colors.black;
          double x = obj["x"] * size.width;
          double y = obj["y"] * size.height;
          double w = obj["width"] * size.width;
          double h = obj["height"] * size.height;
          canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
        }
      }

      // Dibuixar clients (jugadors) amb el seu color assignat
      if (gameState["clients"] != null) {
        for (var client in gameState["clients"]) {
          paint.color = _getColorFromString(client["color"]);
          double x = client["x"] * size.width;
          double y = client["y"] * size.height;
          double w = client["width"] * size.width;
          double h = client["height"] * size.height;
          canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
        }
      }
    }

    // 🔹 Dibuixar text d'ajuda a la cantonada inferior esquerra amb ParagraphBuilder
    final paragraphStyle = ui.ParagraphStyle(textDirection: TextDirection.ltr);
    final textStyle = ui.TextStyle(color: Colors.black, fontSize: 14);
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText("Press Up, Down, Left or Right keys to move");

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: size.width));

    // Posició a baix a l'esquerra
    final offset = Offset(10, size.height - paragraph.height - 5);
    canvas.drawParagraph(paragraph, offset);

    // Dibuixar cercle de connexió
    paint.color = appData.isConnected ? Colors.green : Colors.red;
    canvas.drawCircle(Offset(size.width - 10, 10), 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Sempre es torna a pintar quan es crida `notifyListeners()`
  }

  static Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case "gray":
        return Colors.grey;
      case "green":
        return Colors.green;
      case "blue":
        return Colors.blue;
      case "orange":
        return Colors.orange;
      case "red":
        return Colors.red;
      case "purple":
        return Colors.purple;
      case "black":
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}
