import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'game_layer.dart';
import 'titled_text_filed.dart';

class LayoutLayers extends StatefulWidget {
  const LayoutLayers({super.key});

  @override
  LayoutLayersState createState() => LayoutLayersState();
}

class LayoutLayersState extends State<LayoutLayers> {
  late TextEditingController nameController;
  late TextEditingController xController;
  late TextEditingController yController;
  String tilesSheetFile = "";
  late TextEditingController tileWidthController;
  late TextEditingController tileHeightController;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    xController = TextEditingController();
    yController = TextEditingController();
    tileWidthController = TextEditingController();
    tileHeightController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    xController.dispose();
    yController.dispose();
    tileWidthController.dispose();
    tileHeightController.dispose();
    super.dispose();
  }

  void _updateForm(AppData appData) {
    if (appData.selectedLevel != -1 && appData.selectedLayer != -1) {
      final selectedLayer = appData
          .gameData.levels[appData.selectedLevel].layers[appData.selectedLayer];
      nameController.text = selectedLayer.name;
      xController.text = selectedLayer.x.toString();
      yController.text = selectedLayer.y.toString();
      tilesSheetFile = selectedLayer.tilesSheetFile;
      tileWidthController.text = selectedLayer.tilesWidth.toString();
      tileHeightController.text = selectedLayer.tilesHeight.toString();
    } else {
      nameController.clear();
      xController.clear();
      yController.clear();
      tilesSheetFile = "";
      tileWidthController.clear();
      tileHeightController.clear();
    }
  }

  Future<void> _pickTilesSheet(AppData appData) async {
    tilesSheetFile = await appData.pickTilesSheetFile();
    appData.update();
  }

  void _addLayer(AppData appData) {
    if (appData.selectedLevel == -1) return;

    final newLayer = GameLayer(
      name: nameController.text,
      x: int.tryParse(xController.text) ?? 0,
      y: int.tryParse(yController.text) ?? 0,
      tilesSheetFile: tilesSheetFile,
      tilesWidth: int.tryParse(tileWidthController.text) ?? 32,
      tilesHeight: int.tryParse(tileHeightController.text) ?? 32,
      tileMap: [],
    );

    appData.gameData.levels[appData.selectedLevel].layers.add(newLayer);
    appData.selectedLayer = -1;
    tilesSheetFile = "";
    _updateForm(appData);
    appData.update();
  }

  void _updateLayer(AppData appData) {
    if (appData.selectedLevel != -1 && appData.selectedLayer != -1) {
      final layers = appData.gameData.levels[appData.selectedLevel].layers;
      layers[appData.selectedLayer] = GameLayer(
        name: nameController.text,
        x: int.tryParse(xController.text) ?? 0,
        y: int.tryParse(yController.text) ?? 0,
        tilesSheetFile: tilesSheetFile,
        tilesWidth: int.tryParse(tileWidthController.text) ?? 32,
        tilesHeight: int.tryParse(tileHeightController.text) ?? 32,
        tileMap: layers[appData.selectedLayer].tileMap,
      );
      appData.update();
    }
  }

  void _deleteLayer(AppData appData) {
    if (appData.selectedLevel != -1 && appData.selectedLayer != -1) {
      appData.gameData.levels[appData.selectedLevel].layers
          .removeAt(appData.selectedLayer);
      appData.selectedLayer = -1;
      _updateForm(appData);
      appData.update();
    }
  }

  void _selectLayer(AppData appData, int index, bool isSelected) {
    appData.selectedLayer = isSelected ? -1 : index;
    _updateForm(appData);
    appData.update();
  }

  void _onReorder(AppData appData, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final layers = appData.gameData.levels[appData.selectedLevel].layers;
    final int selectedIndex = appData.selectedLayer;

    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);

    if (selectedIndex == oldIndex) {
      appData.selectedLayer = newIndex;
    } else if (selectedIndex > oldIndex && selectedIndex <= newIndex) {
      appData.selectedLayer -= 1;
    } else if (selectedIndex < oldIndex && selectedIndex >= newIndex) {
      appData.selectedLayer += 1;
    } else {
      appData.selectedLayer = selectedIndex;
    }

    appData.update();

    if (kDebugMode) {
      print(
          "Updated layer order: ${appData.gameData.levels[appData.selectedLevel].layers.map((layer) => layer.name).join(', ')}");
      print("Selected layer remains at index: ${appData.selectedLayer}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    if (appData.selectedLevel == -1) {
      return const Center(
        child: Text(
          'No level selected',
          style: TextStyle(fontSize: 16.0, color: CupertinoColors.systemGrey),
        ),
      );
    }

    final level = appData.gameData.levels[appData.selectedLevel];
    final layers = level.layers;

    final bool isFormFilled = nameController.text.isNotEmpty &&
        xController.text.isNotEmpty &&
        yController.text.isNotEmpty &&
        tilesSheetFile != "" &&
        tileWidthController.text.isNotEmpty &&
        tileHeightController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Editing Layers for level "${level.name}"',
            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            child: layers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '(No layers defined)',
                      style: TextStyle(
                          fontSize: 12.0, color: CupertinoColors.systemGrey),
                    ),
                  )
                : CupertinoScrollbar(
                    controller: scrollController,
                    child: Localizations.override(
                      context: context,
                      delegates: [
                        DefaultMaterialLocalizations
                            .delegate, // Add Material Localizations
                        DefaultWidgetsLocalizations.delegate,
                      ],
                      child: ReorderableListView.builder(
                        //controller: scrollController,
                        itemCount: layers.length,
                        onReorder: (oldIndex, newIndex) =>
                            _onReorder(appData, oldIndex, newIndex),
                        itemBuilder: (context, index) {
                          final isSelected = (index == appData.selectedLayer);
                          return GestureDetector(
                              key: ValueKey(layers[index]), // Reorder value key
                              onTap: () {
                                _selectLayer(appData, index, isSelected);
                              },
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  color: isSelected
                                      ? CupertinoColors.systemBlue
                                          .withOpacity(0.2)
                                      : CupertinoColors.systemBackground,
                                  child: Row(children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            layers[index].name,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            appData
                                                .gameData
                                                .levels[appData.selectedLevel]
                                                .layers[index]
                                                .tilesSheetFile,
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])));
                        },
                      ),
                    ),
                  )),
        const SizedBox(height: 8),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              (appData.selectedLayer == -1) ? 'Add layer:' : 'Modify layer:',
              style:
                  const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            )),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TitledTextfield(
            title: "Layer name",
            controller: nameController,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TitledTextfield(
                  title: 'X position',
                  controller: xController,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitledTextfield(
                  title: 'Y position',
                  controller: yController,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Tiles image:',
              style:
                  const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tilesSheetFile == "" ? "No file selected" : tilesSheetFile,
                  style: const TextStyle(
                      fontSize: 12.0, color: CupertinoColors.systemGrey),
                ),
              ),
              CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: const Text(
                  "Choose File",
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _pickTilesSheet(appData),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TitledTextfield(
                  title: 'Tile width',
                  controller: tileWidthController,
                  placeholder: '32',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitledTextfield(
                  title: 'Tile height',
                  controller: tileHeightController,
                  placeholder: '32',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (appData.selectedLayer != -1) ...[
              CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onPressed: isFormFilled ? () => _updateLayer(appData) : null,
                child: const Text('Update'),
              ),
              CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: CupertinoColors.destructiveRed,
                onPressed: () => _deleteLayer(appData),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ] else
              CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onPressed: isFormFilled ? () => _addLayer(appData) : null,
                child: const Text('Add Layer'),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
