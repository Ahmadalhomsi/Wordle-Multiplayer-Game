class Room {
  final String key;
  final String name;
  final String type;
  final bool isFull;
  final int wordLength;
  final String? player1;
  final String? player2;

  Room({
    required this.key,
    required this.name,
    required this.type,
    required this.isFull,
    required this.wordLength,
    this.player1,
    this.player2,
  });

  // Add the factory constructor here
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      key: json['key'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isFull: json['isFull'] as bool,
      wordLength: json['wordLength'] as int,
    );
  }

  // Convert Room object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'isFull': isFull,
      'wordLength': wordLength,
      'player1': player1,
      'player2': player2,
    };
  }

  factory Room.fromMap(Map<dynamic, dynamic> map, String key) {
    return Room(
      key: key,
      name: map['name'],
      type: map['type'],
      isFull: map['isFull'],
      wordLength: map['wordLength'],
    );
  }
}
