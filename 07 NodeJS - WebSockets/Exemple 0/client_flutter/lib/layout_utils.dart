import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'app_data.dart';

class LayoutUtils {
  static Future<ui.Image> drawCanvasImageTilemap(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    int imageWidth = 10;
    int imageHeight = 10;

    if (appData.selectedLevel != -1 && appData.selectedLayer != -1) {
      final level = appData.gameData.levels[appData.selectedLevel];
      final layer = level.layers[appData.selectedLayer];

      final paintTiles = Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      int rows = layer.tileMap.length;
      int cols = layer.tileMap[0].length;
      double tileWidth = layer.tilesWidth.toDouble();
      double tileHeight = layer.tilesHeight.toDouble();
      double tilemapWidth = cols * tileWidth;
      double tilemapHeight = rows * tileHeight;

      imageWidth = tilemapWidth.toInt();
      imageHeight = tilemapHeight.toInt();

      double imageX, imageY, imageW, imageH;
      imageW = imageWidth * 0.25;
      imageH = imageHeight.toDouble();
      imageX = imageWidth.toDouble() + 10;
      imageY = 0;
      imageWidth = (imageWidth + imageW).toInt() + 10;

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
          double tileX = col * tileWidth;
          double tileY = row * tileHeight;
          imgCanvas.drawRect(
            Rect.fromLTWH(tileX, tileY, tileWidth, tileHeight),
            paintTiles,
          );
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(imageWidth, imageHeight);

      final tilesheetImage = await appData
          .loadImage("${appData.filePath}/${layer.tilesSheetFile}");
      double scaleFactor =
          (imageH / tilesheetImage.height.toDouble()).clamp(0.0, 1.0);
      double scaledWidth = tilesheetImage.width.toDouble() * scaleFactor;
      double scaledHeight = tilesheetImage.height.toDouble() * scaleFactor;
      double centeredX = imageX + (imageW - scaledWidth) / 2;
      double centeredY = imageY + (imageH - scaledHeight) / 2;

      final recorderFinal = ui.PictureRecorder();
      final finalCanvas = Canvas(recorderFinal);
      finalCanvas.drawImage(image, Offset.zero, Paint());
      finalCanvas.drawImageRect(
        tilesheetImage,
        Rect.fromLTWH(0, 0, tilesheetImage.width.toDouble(),
            tilesheetImage.height.toDouble()),
        Rect.fromLTWH(centeredX, centeredY, scaledWidth, scaledHeight),
        Paint(),
      );

      final finalPicture = recorderFinal.endRecording();
      return await finalPicture.toImage(imageWidth, imageHeight);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }
}
