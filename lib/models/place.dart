class Place {
  final String id;
  final String name;
  final String? roomId; // Добавляем поле roomId

  Place({
    required this.id,
    required this.name,
    this.roomId,
  });

  factory Place.fromMap(Map<String, dynamic> map, String id) {
    return Place(
      id: id, // ✅ Передаём `id` из `doc.id`, а не из `map`
      name: map['name'] ??
          'Без названия', // ✅ Защита от null и неправильных типов
      roomId: map['roomId'] != null
          ? map['roomId'] as String
          : null, // ✅ Безопасная обработка `roomId`
    );
  }

/*
  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] ?? '', // ✅ Проверяем, есть ли 'id'
      name: map['name'] ?? 'Без названия', // ✅ Проверяем 'name'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }*/
}
