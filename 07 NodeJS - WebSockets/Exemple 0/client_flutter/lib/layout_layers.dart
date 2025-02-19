import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'app_data.dart';
import 'game_layer.dart';

class LayoutLayers extends StatefulWidget {
  const LayoutLayers({super.key});

  @override
  LayoutLayersState createState() => LayoutLayersState();
}

class LayoutLayersState extends State<LayoutLayers> {
  int selectedLayerIndex = -1;
  late TextEditingController nameController;
  late TextEditingController spriteWidthController;
  late TextEditingController spriteHeightController;
  String spriteSheetFilePath = "";
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    spriteWidthController = TextEditingController();
    spriteHeightController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    spriteWidthController.dispose();
    spriteHeightController.dispose();
    super.dispose();
  }

  void _updateForm(AppData appData) {
    if (appData.selectedLevel != -1 && selectedLayerIndex != -1) {
      final selectedLayer = appData
          .gameData.levels[appData.selectedLevel].layers[selectedLayerIndex];
      nameController.text = selectedLayer.name;
      spriteSheetFilePath = selectedLayer.spriteSheetFile;
      spriteWidthController.text = selectedLayer.spriteWidth.toString();
      spriteHeightController.text = selectedLayer.spriteHeight.toString();
    } else {
      nameController.clear();
      spriteSheetFilePath = "";
      spriteWidthController.clear();
      spriteHeightController.clear();
    }
  }

  Future<void> _pickSpriteSheet(AppData appData) async {
    final path = await appData.pickSpriteSheetFile();
    if (path != null) {
      setState(() {
        spriteSheetFilePath = path;
      });
    }
  }

  void _addLayer(AppData appData) {
    if (appData.selectedLevel == -1) return;

    final newLayer = GameLayer(
      name: nameController.text,
      spriteSheetFile: spriteSheetFilePath,
      spriteWidth: int.tryParse(spriteWidthController.text) ?? 32,
      spriteHeight: int.tryParse(spriteHeightController.text) ?? 32,
      spriteMatrix: [],
    );

    appData.gameData.levels[appData.selectedLevel].layers.add(newLayer);
    appData.update();

    setState(() {
      selectedLayerIndex = -1;
      _updateForm(appData);
    });
  }

  void _updateLayer(AppData appData) {
    if (appData.selectedLevel != -1 && selectedLayerIndex != -1) {
      final layers = appData.gameData.levels[appData.selectedLevel].layers;
      layers[selectedLayerIndex] = GameLayer(
        name: nameController.text,
        spriteSheetFile: spriteSheetFilePath,
        spriteWidth: int.tryParse(spriteWidthController.text) ?? 32,
        spriteHeight: int.tryParse(spriteHeightController.text) ?? 32,
        spriteMatrix: layers[selectedLayerIndex].spriteMatrix,
      );

      appData.update();
      setState(() {});
    }
  }

  void _deleteLayer(AppData appData) {
    if (appData.selectedLevel != -1 && selectedLayerIndex != -1) {
      appData.gameData.levels[appData.selectedLevel].layers
          .removeAt(selectedLayerIndex);
      appData.update();
      setState(() {
        selectedLayerIndex = -1;
        _updateForm(appData);
      });
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
    final bool isFormFilled = nameController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Editing Layers for: ${level.name}',
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
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: layers.length,
                    itemBuilder: (context, index) {
                      final isSelected = (index == selectedLayerIndex);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLayerIndex = isSelected ? -1 : index;
                            _updateForm(appData);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          color: isSelected
                              ? CupertinoColors.systemBlue.withOpacity(0.2)
                              : CupertinoColors.systemBackground,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                layers[index].spriteSheetFile,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CupertinoTextField(
            controller: nameController,
            placeholder: 'Layer Name',
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  spriteSheetFilePath.isEmpty
                      ? "No file selected"
                      : spriteSheetFilePath,
                  style: const TextStyle(
                      fontSize: 12.0, color: CupertinoColors.systemGrey),
                ),
              ),
              CupertinoButton(
                child: const Text("Choose File"),
                onPressed: () => _pickSpriteSheet(appData),
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
                child: CupertinoTextField(
                  controller: spriteWidthController,
                  placeholder: 'Sprite Width',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoTextField(
                  controller: spriteHeightController,
                  placeholder: 'Sprite Height',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
