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

  factory Room.fromJson(Map<String, dynamic> json, String key) {
    print('key:' + key);
    return Room(
      key: key,
      isFull: json['isFull'],
      name: json['name'],
      player1: json['player1'],
      type: json['type'],
      wordLength: json['wordLength'],
      player2: json['player2'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Room(key: $key, name: $name, type: $type, isFull: $isFull, wordLength: $wordLength)';
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
