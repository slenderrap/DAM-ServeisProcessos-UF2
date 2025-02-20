import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'game_zone.dart';
import 'titled_text_filed.dart';

class LayoutZones extends StatefulWidget {
  const LayoutZones({super.key});
  @override
  LayoutZonesState createState() => LayoutZonesState();
}

class LayoutZonesState extends State<LayoutZones> {
  late TextEditingController typeController;
  late TextEditingController xController;
  late TextEditingController yController;
  late TextEditingController widthController;
  late TextEditingController heightController;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController();
    xController = TextEditingController();
    yController = TextEditingController();
    widthController = TextEditingController();
    heightController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appData = Provider.of<AppData>(context, listen: false);
      _updateForm(appData);
    });
  }

  @override
  void dispose() {
    typeController.dispose();
    xController.dispose();
    yController.dispose();
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _updateForm(AppData appData) {
    if (appData.selectedZone != -1 && appData.selectedLevel != -1) {
      final zone = appData
          .gameData.levels[appData.selectedLevel].zones[appData.selectedZone];
      typeController.text = zone.type;
      xController.text = zone.x.toString();
      yController.text = zone.y.toString();
      widthController.text = zone.width.toString();
      heightController.text = zone.height.toString();
    } else {
      typeController.clear();
      xController.clear();
      yController.clear();
      widthController.clear();
      heightController.clear();
    }
  }

  void _addZone(AppData appData) {
    if (appData.selectedLevel == -1) return;
    final newZone = GameZone(
      type: typeController.text,
      x: int.tryParse(xController.text) ?? 0,
      y: int.tryParse(yController.text) ?? 0,
      width: int.tryParse(widthController.text) ?? 0,
      height: int.tryParse(heightController.text) ?? 0,
    );
    appData.gameData.levels[appData.selectedLevel].zones.add(newZone);
    appData.selectedZone = -1;
    _updateForm(appData);
    appData.update();
  }

  void _updateZone(AppData appData) {
    if (appData.selectedZone != -1 && appData.selectedLevel != -1) {
      appData.gameData.levels[appData.selectedLevel]
          .zones[appData.selectedZone] = GameZone(
        type: typeController.text,
        x: int.tryParse(xController.text) ?? 0,
        y: int.tryParse(yController.text) ?? 0,
        width: int.tryParse(widthController.text) ?? 0,
        height: int.tryParse(heightController.text) ?? 0,
      );
      appData.update();
    }
  }

  void _deleteZone(AppData appData) {
    if (appData.selectedZone != -1 && appData.selectedLevel != -1) {
      appData.gameData.levels[appData.selectedLevel].zones
          .removeAt(appData.selectedZone);
      appData.selectedZone = -1;
      _updateForm(appData);
      appData.update();
    }
  }

  void _selectZone(AppData appData, int index, bool isSelected) {
    appData.selectedZone = isSelected ? -1 : index;
    _updateForm(appData);
    appData.update();
  }

  void _onReorder(AppData appData, int oldIndex, int newIndex) {
    if (appData.selectedLevel == -1) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final zones = appData.gameData.levels[appData.selectedLevel].zones;
    final int selectedIndex = appData.selectedZone;
    final item = zones.removeAt(oldIndex);
    zones.insert(newIndex, item);
    if (selectedIndex == oldIndex) {
      appData.selectedZone = newIndex;
    } else if (selectedIndex > oldIndex && selectedIndex <= newIndex) {
      appData.selectedZone -= 1;
    } else if (selectedIndex < oldIndex && selectedIndex >= newIndex) {
      appData.selectedZone += 1;
    }
    appData.update();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    if (appData.selectedLevel == -1) {
      return const Center(child: Text('Select a level to edit zones.'));
    }
    final zones = appData.gameData.levels[appData.selectedLevel].zones;
    bool isFormFilled = typeController.text.isNotEmpty &&
        xController.text.isNotEmpty &&
        yController.text.isNotEmpty &&
        widthController.text.isNotEmpty &&
        heightController.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Zones:',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: zones.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '(No zones defined)',
                    style: TextStyle(
                        fontSize: 12.0, color: CupertinoColors.systemGrey),
                  ),
                )
              : CupertinoScrollbar(
                  controller: scrollController,
                  child: Localizations.override(
                    context: context,
                    delegates: [
                      DefaultMaterialLocalizations.delegate,
                      DefaultWidgetsLocalizations.delegate,
                    ],
                    child: ReorderableListView.builder(
                      itemCount: zones.length,
                      onReorder: (oldIndex, newIndex) =>
                          _onReorder(appData, oldIndex, newIndex),
                      itemBuilder: (context, index) {
                        final isSelected = (index == appData.selectedZone);
                        return GestureDetector(
                          key: ValueKey(zones[index]),
                          onTap: () => _selectZone(appData, index, isSelected),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            color: isSelected
                                ? CupertinoColors.systemBlue.withOpacity(0.2)
                                : CupertinoColors.systemBackground,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(zones[index].type,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                      const SizedBox(height: 2),
                                      Text(
                                          'x: ${zones[index].x}, y: ${zones[index].y}',
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              color:
                                                  CupertinoColors.systemGrey)),
                                      const SizedBox(height: 2),
                                      Text(
                                          'width: ${zones[index].width}, height: ${zones[index].height}',
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              color:
                                                  CupertinoColors.systemGrey)),
                                    ],
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
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            (appData.selectedZone == -1) ? 'New zone:' : 'Modify zone:',
            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TitledTextfield(
            title: 'Zone type',
            controller: typeController,
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
                  title: 'X (px)',
                  controller: xController,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitledTextfield(
                  title: 'Y (px)',
                  controller: yController,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitledTextfield(
                  title: 'Width (px)',
                  controller: widthController,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitledTextfield(
                  title: 'Height (px)',
                  controller: heightController,
                  placeholder: '0',
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
            if (appData.selectedZone != -1) ...[
              CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onPressed: isFormFilled ? () => _updateZone(appData) : null,
                child: const Text('Update'),
              ),
              CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: CupertinoColors.destructiveRed,
                onPressed: () => _deleteZone(appData),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ] else
              CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onPressed: isFormFilled ? () => _addZone(appData) : null,
                child: const Text('Add Zone'),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
