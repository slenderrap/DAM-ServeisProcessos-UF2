import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'canvas_painter.dart';
import 'layout_game.dart';
import 'layout_sprites.dart';
import 'layout_layers.dart';
import 'layout_levels.dart';
import 'layout_media.dart';
import 'layout_tilemaps.dart';
import 'layout_zones.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.title});

  final String title;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  ui.Image? _layerImage;
  List<String> sections = [
    'game',
    'levels',
    'layers',
    'tilemap',
    'zones',
    'sprites',
    'media'
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appData = Provider.of<AppData>(context, listen: false);
      appData.selectedSection = 'game';
    });
  }

  void _onTabSelected(AppData appData, String value) {
    setState(() {
      appData.selectedSection = value;
    });
  }

  Map<String, Widget> _buildSegmentedChildren() {
    return {
      for (var segment in sections)
        segment: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            segment[0].toUpperCase() +
                segment.substring(1), // Capitalitza la primera lletra
            style: const TextStyle(fontSize: 12.0),
          ),
        ),
    };
  }

  Widget _getSelectedLayout(AppData appData) {
    switch (appData.selectedSection) {
      case 'game':
        return const LayoutGame();
      case 'levels':
        return const LayoutLevels();
      case 'layers':
        return const LayoutLayers();
      case 'tilemap':
        return const LayoutTilemaps();
      case 'zones':
        return const LayoutZones();
      case 'sprites':
        return const LayoutSprites();
      case 'media':
        return const LayoutMedia();
      default:
        return const Center(child: Text('Unknown Layout'));
    }
  }

  Future<void> _drawCanvasImage(AppData appData) async {
    ui.Image image;
    switch (appData.selectedSection) {
      case 'game':
        image = await _drawCanvasImageGame(appData);
      case 'levels':
        image = await _drawCanvasImageLevels(appData);
      case 'layers':
        image = await _drawCanvasImageLayers(appData);
      case 'tilemap':
        image = await _drawCanvasImageTilemap(appData);
      case 'zones':
        image = await _drawCanvasImageZones(appData);
      case 'sprites':
        image = await _drawCanvasImageSprites(appData);
      case 'media':
        image = await _drawCanvasImageMedia(appData);
      default:
        image = await _drawCanvasImageEmpty(appData);
    }

    setState(() {
      _layerImage = image;
    });
  }

  Future<ui.Image> _drawCanvasImageGame(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }

  Future<ui.Image> _drawCanvasImageLevels(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }

  Future<ui.Image> _drawCanvasImageLayers(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    int imageWidth = 10;
    int imageHeight = 10;

    if (appData.selectedLevel != -1) {
      final level = appData.gameData.levels[appData.selectedLevel];
      final layers = level.layers;
      final paintTiles = Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      for (int cntLayer = 0;
          cntLayer < layers.length;
          cntLayer = cntLayer + 1) {
        final layer = layers[cntLayer];

        double x = layer.x.toDouble();
        double y = layer.y.toDouble();
        int rows = layer.tileMap.length;
        int cols = layer.tileMap[0].length;
        double tileWidth = layer.tilesWidth.toDouble();
        double tileHeight = layer.tilesHeight.toDouble();

        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < cols; col++) {
            double tileX = x + col * tileWidth;
            double tileY = y + row * tileHeight;

            // Dibuixa el rectangle de cada tile
            imgCanvas.drawRect(
              Rect.fromLTWH(tileX, tileY, tileWidth, tileHeight),
              paintTiles,
            );
          }
        }

        // Actualitza la mida màxima de la imatge
        double endX = x + cols * tileWidth;
        double endY = y + rows * tileHeight;
        if (endX > imageWidth) {
          imageWidth = endX.toInt();
        }
        if (endY > imageHeight) {
          imageHeight = endY.toInt();
        }
      }

      if (appData.selectedLayer != -1) {
        Paint paintSelected = Paint()
          ..color = Colors.blue
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke;
        final layer = level.layers[appData.selectedLayer];
        double x = layer.x.toDouble();
        double y = layer.y.toDouble();
        double width = layer.tileMap[0].length * layer.tilesWidth.toDouble();
        double height = layer.tileMap.length * layer.tilesHeight.toDouble();
        imgCanvas.drawRect(
          Rect.fromLTWH(x + 2.5, y + 2.5, width - 5, height - 5),
          paintSelected,
        );
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(imageWidth, imageHeight);
    return image;
  }

  Future<ui.Image> _drawCanvasImageTilemap(AppData appData) async {
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

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
          double tileX = col * tileWidth;
          double tileY = row * tileHeight;

          // Dibuixa el rectangle de cada tile
          imgCanvas.drawRect(
            Rect.fromLTWH(tileX, tileY, tileWidth, tileHeight),
            paintTiles,
          );
        }
      }

      // Actualitza la mida màxima de la imatge
      imageWidth = (cols * tileWidth).toInt();
      imageHeight = (rows * tileHeight).toInt();
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(imageWidth, imageHeight);
    return image;
  }

  Future<ui.Image> _drawCanvasImageZones(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }

  Future<ui.Image> _drawCanvasImageSprites(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }

  Future<ui.Image> _drawCanvasImageMedia(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final imgCanvas = Canvas(recorder);

    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }

  Future<ui.Image> _drawCanvasImageEmpty(AppData appData) async {
    final recorder = ui.PictureRecorder();
    final picture = recorder.endRecording();
    final image = await picture.toImage(10, 10);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final level = appData.selectedLevel != -1
        ? appData.gameData.levels[appData.selectedLevel].name
        : "";
    final layer = appData.selectedLayer != -1
        ? appData.gameData.levels[appData.selectedLevel]
            .layers[appData.selectedLayer].name
        : "";

    final location = Text.rich(
      overflow: TextOverflow.ellipsis,
      TextSpan(
        children: [
          if (level != "") ...[
            TextSpan(
              text: "Level: ",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextSpan(
              text: "$level ",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
          if (layer != "") ...[
            TextSpan(
              text: "Layer: ",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextSpan(
              text: "$layer ",
              style: TextStyle(fontSize: 14, color: Colors.black),
            )
          ]
        ],
      ),
    );

    _drawCanvasImage(appData);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: 250,
                child: Align(alignment: Alignment.centerLeft, child: location)),
            Spacer(),
            CupertinoSegmentedControl<String>(
              onValueChanged: (value) => _onTabSelected(appData, value),
              groupValue: appData.selectedSection,
              children: _buildSegmentedChildren(),
            ),
            Spacer(),
            SizedBox(width: 250, child: Container())
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: CupertinoColors.systemGrey5,
                    child: CustomPaint(
                      painter: _layerImage != null
                          ? CanvasPainter(_layerImage!)
                          : null,
                      child: Container(),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 350, minWidth: 350),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _getSelectedLayout(appData),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
