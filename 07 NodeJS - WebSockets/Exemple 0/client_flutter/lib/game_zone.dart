class GameZone {
  final String type;
  final int x;
  final int y;
  final int width;
  final int height;

  GameZone({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  // Constructor de fàbrica per crear una instància des d'un Map (JSON)
  factory GameZone.fromJson(Map<String, dynamic> json) {
    return GameZone(
      type: json['type'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
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
    };
  }

  @override
  String toString() {
    return 'GameZone(type: $type, x: $x, y: $y, width: $width, height: $height)';
  }
}
