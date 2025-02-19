class GameItem {
  final String type;
  final int x;
  final int y;
  final int width;
  final int height;
  final String imageFile;

  GameItem({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.imageFile,
  });

  // Constructor de fàbrica per crear una instància des d'un Map (JSON)
  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      type: json['type'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      imageFile: json['imageFile'] as String,
    );
  }

  // Convertir l'objecte a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'imageFile': imageFile,
    };
  }

  @override
  String toString() {
    return 'GameItem(type: $type, x: $x, y: $y, width: $width, height: $height, imageFile: $imageFile)';
  }
}
