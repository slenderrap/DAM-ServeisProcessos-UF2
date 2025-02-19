class GameLayer {
  final String spriteSheetFile;
  final int spriteWidth;
  final int spriteHeight;
  final List<List<int>> spriteMatrix;

  GameLayer({
    required this.spriteSheetFile,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.spriteMatrix,
  });

  // Constructor de fàbrica per crear una instància des d'un Map (JSON)
  factory GameLayer.fromJson(Map<String, dynamic> json) {
    return GameLayer(
      spriteSheetFile: json['spriteSheetFile'] as String,
      spriteWidth: json['spriteWidth'] as int,
      spriteHeight: json['spriteHeight'] as int,
      spriteMatrix: (json['spriteMatrix'] as List<dynamic>)
          .map((row) => List<int>.from(row))
          .toList(),
    );
  }

  // Convertir l'objecte a JSON
  Map<String, dynamic> toJson() {
    return {
      'spriteSheetFile': spriteSheetFile,
      'spriteWidth': spriteWidth,
      'spriteHeight': spriteHeight,
      'spriteMatrix': spriteMatrix.map((row) => row.toList()).toList(),
    };
  }

  @override
  String toString() {
    return 'GameLayer(spriteSheetFile: $spriteSheetFile, spriteWidth: $spriteWidth, spriteHeight: $spriteHeight, spriteMatrix: $spriteMatrix)';
  }
}
