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
  late String _selectedSegment;
  List<String> segments = [
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
    _selectedSegment = 'game';
  }

  void _onTabSelected(String value) {
    setState(() {
      _selectedSegment = value;
    });
  }

  Map<String, Widget> _buildSegmentedChildren() {
    return {
      for (var segment in segments)
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

  Widget _getSelectedLayout() {
    switch (_selectedSegment) {
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
              onValueChanged: _onTabSelected,
              groupValue: _selectedSegment,
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
                      painter: CanvasPainter(),
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
                        child: _getSelectedLayout(),
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
