import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'canvas_painter.dart';
import 'layout_layers.dart';
import 'layout_level.dart';
import 'layout_media.dart';
import 'layout_zones.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.title});

  final String title;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late String _selectedSegment;
  List<String> segments = ['level', 'layers', 'zones', 'media'];

  @override
  void initState() {
    super.initState();
    _selectedSegment = 'level';
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
      case 'level':
        return const LayoutLevel();
      case 'layers':
        return const LayoutLayers();
      case 'zones':
        return const LayoutZones();
      case 'media':
        return const LayoutMedia();
      default:
        return const Center(child: Text('Unknown Layout'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final ScrollController scrollController = ScrollController();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
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
                      painter: CanvasPainter(
                        drawables: appData.drawables,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Expanded(
                    flex: 1,
                    child: CupertinoScrollbar(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          CupertinoSegmentedControl<String>(
                            onValueChanged: _onTabSelected,
                            groupValue: _selectedSegment,
                            children: _buildSegmentedChildren(),
                          ),
                          const SizedBox(
                              height:
                                  16), // Espai després del segmented control
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: CupertinoScrollbar(
                                controller: scrollController,
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: _getSelectedLayout(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
