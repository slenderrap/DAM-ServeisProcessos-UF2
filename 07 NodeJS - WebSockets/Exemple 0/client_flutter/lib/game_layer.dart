class GameLayer {
  final String name;
  final int x;
  final int y;
  final String tilesSheetFile;
  final int tilesWidth;
  final int tilesHeight;
  final List<List<int>> tileMap;

  GameLayer({
    required this.name,
    required this.x,
    required this.y,
    required this.tilesSheetFile,
    required this.tilesWidth,
    required this.tilesHeight,
    required this.tileMap,
  });

  // Constructor de fàbrica per crear una instància des d'un Map (JSON)
  factory GameLayer.fromJson(Map<String, dynamic> json) {
    return GameLayer(
      name: json['name'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      tilesSheetFile: json['tilesSheetFile'] as String,
      tilesWidth: json['tilesWidth'] as int,
      tilesHeight: json['tilesHeight'] as int,
      tileMap: (json['tileMap'] as List<dynamic>)
          .map((row) => List<int>.from(row))
          .toList(),
    );
  }

  // Convertir l'objecte a JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'x': x,
      'y': y,
      'tilesSheetFile': tilesSheetFile,
      'tilesWidth': tilesWidth,
      'tilesHeight': tilesHeight,
      'tileMap': tileMap.map((row) => row.toList()).toList(),
    };
  }

  @override
  String toString() {
    return 'GameLayer(name: $name, x: $x, y: $y, tilesSheetFile: $tilesSheetFile, tilesWidth: $tilesWidth, tilesHeight: $tilesHeight, tileMap: $tileMap)';
  }
}
