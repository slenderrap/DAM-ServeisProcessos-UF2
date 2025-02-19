import 'game_layer.dart';
import 'game_zone.dart';

class GameLevel {
  final int id;
  final String name;
  final String description;
  final String file;
  final List<GameLayer> layers;
  final List<GameZone> zones;

  GameLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.file,
    required this.layers,
    required this.zones,
  });

  // Constructor de fàbrica per crear una instància des d'un Map (JSON)
  factory GameLevel.fromJson(Map<String, dynamic> json) {
    return GameLevel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      file: json['file'] as String,
      layers: (json['layers'] as List<dynamic>)
          .map((layer) => GameLayer.fromJson(layer))
          .toList(),
      zones: (json['zones'] as List<dynamic>)
          .map((zone) => GameZone.fromJson(zone))
          .toList(),
    );
  }

  // Convertir l'objecte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'file': file,
      'layers': layers.map((layer) => layer.toJson()).toList(),
      'zones': zones.map((zone) => zone.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'GameLevel(id: $id, name: $name, description: $description, file: $file, layers: $layers, zones: $zones)';
  }
}
