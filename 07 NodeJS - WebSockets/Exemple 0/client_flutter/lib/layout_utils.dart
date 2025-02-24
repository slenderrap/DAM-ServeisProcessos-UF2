import 'dart:async';
import 'dart:ui' as ui;

import 'package:exemple0700/game_layer.dart';
import 'package:flutter/material.dart';
import 'app_data.dart';

class LayoutUtils {
  static Future<ui.Image> generateTilemapWithGrid(
      AppData appData, int levelIndex, int layerIndex) async {
    final level = appData.gameData.levels[levelIndex];
    final layer = level.layers[layerIndex];

    int rows = layer.tileMap.length;
    int cols = layer.tileMap[0].length;
    double tileWidth = layer.tilesWidth.toDouble();
    double tileHeight = layer.tilesHeight.toDouble();
    double tilemapWidth = cols * tileWidth;
    double tilemapHeight = rows * tileHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final ui.Image tilesetImage = await appData.getImage(layer.tilesSheetFile);

    // Obtenir el nombre de columnes al tileset
    int tilesetColumns = (tilesetImage.width / tileWidth).floor();

    // Dibuixar els tiles segons el `tileMap`
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        int tileIndex = layer.tileMap[row][col];

        if (tileIndex >= 0) {
          // Només dibuixar si el tileIndex és vàlid
          int tileRow = (tileIndex / tilesetColumns).floor();
          int tileCol = (tileIndex % tilesetColumns);

          double tileX = tileCol * tileWidth;
          double tileY = tileRow * tileHeight;

          // Posició al tilemap
          double destX = col * tileWidth;
          double destY = row * tileHeight;

          // 🔹 Dibuixar el tile corresponent
          canvas.drawImageRect(
            tilesetImage,
            Rect.fromLTWH(tileX, tileY, tileWidth, tileHeight),
            Rect.fromLTWH(destX, destY, tileWidth, tileHeight),
            Paint(),
          );
        }
      }
    }

    // Dibuixar la quadrícula al damunt dels tiles
    final gridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int row = 0; row <= rows; row++) {
      double y = row * tileHeight;
      canvas.drawLine(Offset(0, y), Offset(tilemapWidth, y), gridPaint);
    }

    for (int col = 0; col <= cols; col++) {
      double x = col * tileWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, tilemapHeight), gridPaint);
    }

    final picture = recorder.endRecording();
    return await picture.toImage(tilemapWidth.toInt(), tilemapHeight.toInt());
  }

  static Future<ui.Image> generateTilesetWithGrid(AppData appData,
      String tilesetPath, double tileWidth, double tileHeight) async {
    final tilesheetImage = await appData.getImage(tilesetPath);

    double imageWidth = tilesheetImage.width.toDouble();
    double imageHeight = tilesheetImage.height.toDouble();

    int tilesetColumns = (imageWidth / tileWidth).floor();
    int tilesetRows = (imageHeight / tileHeight).floor();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(tilesheetImage, Offset.zero, Paint());

    final gridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int row = 0; row <= tilesetRows; row++) {
      double y = row * tileHeight;
      canvas.drawLine(Offset(0, y), Offset(imageWidth, y), gridPaint);
    }

    for (int col = 0; col <= tilesetColumns; col++) {
      double x = col * tileWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, imageHeight), gridPaint);
    }

    final picture = recorder.endRecording();
    final tilesetImage =
        await picture.toImage(imageWidth.toInt(), imageHeight.toInt());

    return tilesetImage;
  }

  static Future<ui.Image> drawCanvasImageEmpty(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Cal dibuixar algo perquè "recorder" no falli
    canvas.drawRect(
        Rect.fromLTWH(0, 0, 10, 10), Paint()..color = Colors.transparent);

    final picture = recorder.endRecording();
    return await picture.toImage(10, 10);
  }

  static Future<ui.Image> drawCanvasImageLayers(AppData appData) async {
    if (appData.selectedLevel == -1) {
      return await drawCanvasImageEmpty(appData);
    }

    final level = appData.gameData.levels[appData.selectedLevel];
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    int imageWidth = 10;
    int imageHeight = 10;

    for (var layer in level.layers) {
      // Generar la imatge del tilemap per a aquesta capa
      final tilemapImage = await generateTilemapWithGrid(
          appData, appData.selectedLevel, level.layers.indexOf(layer));

      // Posicionar la imatge de la capa a la seva coordenada (x, y)
      imgCanvas.drawImage(tilemapImage,
          Offset(layer.x.toDouble(), layer.y.toDouble()), Paint());

      // Actualitzar la mida total de la imatge
      imageWidth = imageWidth > (layer.x + tilemapImage.width)
          ? imageWidth
          : (layer.x + tilemapImage.width);
      imageHeight = imageHeight > (layer.y + tilemapImage.height)
          ? imageHeight
          : (layer.y + tilemapImage.height);
    }

    // Si hi ha una capa seleccionada, dibuixar-ne el contorn en blau
    if (appData.selectedLayer != -1) {
      final layer = level.layers[appData.selectedLayer];
      final paintSelected = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      imgCanvas.drawRect(
        Rect.fromLTWH(
            layer.x + 1,
            layer.y + 1,
            layer.tileMap[0].length * layer.tilesWidth - 2,
            layer.tileMap.length * layer.tilesHeight - 2),
        paintSelected,
      );
    }

    final picture = recorder.endRecording();
    return await picture.toImage(imageWidth, imageHeight);
  }

  static Future<ui.Image> drawCanvasImageTilemap(AppData appData) async {
    if (appData.selectedLevel == -1 || appData.selectedLayer == -1) {
      return await drawCanvasImageEmpty(appData);
    }

    final level = appData.gameData.levels[appData.selectedLevel];
    final layer = level.layers[appData.selectedLayer];

    await appData.getImage(layer.tilesSheetFile);

    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    // Obtenir imatge del tilemap amb la quadrícula
    final tilemapImage = await generateTilemapWithGrid(
        appData, appData.selectedLevel, appData.selectedLayer);

    // Calcular l'escala i la posició del tilemap al canvas
    double availableWidth = tilemapImage.width * 0.95;
    double availableHeight = tilemapImage.height * 0.95;

    double scaleX = availableWidth / tilemapImage.width;
    double scaleY = availableHeight / tilemapImage.height;
    double tilemapScale = scaleX < scaleY ? scaleX : scaleY;

    double scaledTilemapWidth = tilemapImage.width * tilemapScale;
    double scaledTilemapHeight = tilemapImage.height * tilemapScale;

    double tilemapX = (tilemapImage.width - scaledTilemapWidth) / 2;
    double tilemapY = (tilemapImage.height - scaledTilemapHeight) / 2;

    // Guardar offset i escala del tilemap a AppData
    appData.tilemapOffset = Offset(tilemapX, tilemapY);
    appData.tilemapScaleFactor = tilemapScale;

    imgCanvas.drawImageRect(
      tilemapImage,
      Rect.fromLTWH(
          0, 0, tilemapImage.width.toDouble(), tilemapImage.height.toDouble()),
      Rect.fromLTWH(
          tilemapX, tilemapY, scaledTilemapWidth, scaledTilemapHeight),
      Paint(),
    );

    // Obtenir imatge del tileset amb la quadrícula
    final tilesetImage = await generateTilesetWithGrid(
        appData,
        layer.tilesSheetFile,
        layer.tilesWidth.toDouble(),
        layer.tilesHeight.toDouble());

    // Calcular la posició i mida escalada del tileset
    double tilesetMaxWidth = tilemapImage.width * 0.5;
    double tilesetMaxHeight = tilemapImage.height.toDouble();
    double tilesetX = tilemapImage.width + 10;

    double tilesetScale =
        (tilesetMaxWidth / tilesetImage.width).clamp(0.0, 1.0);
    if (tilesetImage.height * tilesetScale > tilesetMaxHeight) {
      tilesetScale = (tilesetMaxHeight / tilesetImage.height).clamp(0.0, 1.0);
    }

    double scaledTilesetWidth = tilesetImage.width * tilesetScale;
    double scaledTilesetHeight = tilesetImage.height * tilesetScale;
    double centeredTilesetX =
        tilesetX + (tilesetMaxWidth - scaledTilesetWidth) / 2;
    double centeredTilesetY = (tilesetMaxHeight - scaledTilesetHeight) / 2;

    // Guardar offset i escala del tileset a AppData
    appData.tilesetOffset = Offset(centeredTilesetX, centeredTilesetY);
    appData.tilesetScaleFactor = tilesetScale;

    // Dibuixar el tileset escalat amb la quadrícula
    imgCanvas.drawImageRect(
      tilesetImage,
      Rect.fromLTWH(
          0, 0, tilesetImage.width.toDouble(), tilesetImage.height.toDouble()),
      Rect.fromLTWH(centeredTilesetX, centeredTilesetY, scaledTilesetWidth,
          scaledTilesetHeight),
      Paint(),
    );

    final picture = recorder.endRecording();
    return await picture.toImage(
        (tilemapImage.width + tilesetMaxWidth + 10).toInt(),
        tilemapImage.height);
  }

  static Offset translateCoords(
      Offset coords, Offset offset, double scaleFactor) {
    return Offset(
      (coords.dx - offset.dx) / scaleFactor,
      (coords.dy - offset.dy) / scaleFactor,
    );
  }

  static Future<int> tileIndexFromTilesetCoords(
      Offset coords, AppData appData, GameLayer layer) async {
    final tilesheetImage = await appData.getImage(layer.tilesSheetFile);

    double imageWidth = tilesheetImage.width.toDouble();
    double imageHeight = tilesheetImage.height.toDouble();

    // Si està fora dels límits del tileset, retornem -1
    if (coords.dx < 0 ||
        coords.dy < 0 ||
        coords.dx >= imageWidth ||
        coords.dy >= imageHeight) {
      return -1;
    }

    // Calcular la columna i la fila del tile
    int col = (coords.dx / layer.tilesWidth).floor();
    int row = (coords.dy / layer.tilesHeight).floor();

    int tilesetColumns = (imageWidth / layer.tilesWidth).floor();

    // Retornar l'índex del tile dins del tileset
    return row * tilesetColumns + col;
  }

  static Future<void> dragTileIndexFromTileset(
      AppData appData, Offset localPosition) async {
    if (appData.selectedLevel == -1 || appData.selectedLayer == -1) {
      return;
    }

    final level = appData.gameData.levels[appData.selectedLevel];
    final layer = level.layers[appData.selectedLayer];

    if (layer.tilesWidth <= 0 || layer.tilesHeight <= 0) {
      return;
    }

    // Convertir de coordenades de canvas a coordenades d'imatge
    Offset imageCoords = translateCoords(
        localPosition, appData.imageOffset, appData.scaleFactor);

    // Convertir de coordenades d'imatge a coordenades del tileset
    Offset tilesetCoords = translateCoords(
        imageCoords, appData.tilesetOffset, appData.tilesetScaleFactor);

    appData.draggingTileIndex =
        await tileIndexFromTilesetCoords(tilesetCoords, appData, layer);
    appData.draggingOffset = localPosition;
  }

  static Offset? getTilemapCoords(AppData appData, Offset localPosition) {
    if (appData.selectedLevel == -1 || appData.selectedLayer == -1) {
      return null;
    }

    final level = appData.gameData.levels[appData.selectedLevel];
    final layer = level.layers[appData.selectedLayer];

    if (layer.tilesWidth <= 0 || layer.tilesHeight <= 0) {
      return null;
    }

    // Convertir de coordenades de canvas a coordenades d'imatge
    Offset imageCoords = translateCoords(
        localPosition, appData.imageOffset, appData.scaleFactor);

    // Convertir de coordenades d'imatge a coordenades del tilemap
    Offset tilemapCoords = translateCoords(
        imageCoords, appData.tilemapOffset, appData.tilemapScaleFactor);

    double tilemapWidth = layer.tilesWidth * layer.tileMap[0].length.toDouble();
    double tilemapHeight = layer.tilesHeight * layer.tileMap.length.toDouble();

    // Verificar si està fora dels límits del tilemap
    if (tilemapCoords.dx < 0 ||
        tilemapCoords.dy < 0 ||
        tilemapCoords.dx >= tilemapWidth ||
        tilemapCoords.dy >= tilemapHeight) {
      return null;
    }

    // Calcular la fila i columna al tilemap
    int col = (tilemapCoords.dx / layer.tilesWidth).floor();
    int row = (tilemapCoords.dy / layer.tilesHeight).floor();

    return Offset(row.toDouble(), col.toDouble());
  }

  static void dropTileIndexFromTileset(AppData appData, Offset localPosition) {
    Offset? tileCoords = getTilemapCoords(appData, localPosition);
    if (tileCoords == null) return;

    final level = appData.gameData.levels[appData.selectedLevel];
    final layer = level.layers[appData.selectedLayer];

    int row = tileCoords.dx.toInt();
    int col = tileCoords.dy.toInt();

    layer.tileMap[row][col] = appData.draggingTileIndex;
  }

  static void removeTileIndexFromTileset(
      AppData appData, Offset localPosition) {
    Offset? tileCoords = getTilemapCoords(appData, localPosition);
    if (tileCoords == null) return;

    final level = appData.gameData.levels[appData.selectedLevel];
    final layer = level.layers[appData.selectedLayer];

    int row = tileCoords.dx.toInt();
    int col = tileCoords.dy.toInt();

    layer.tileMap[row][col] = -1;
  }
}
