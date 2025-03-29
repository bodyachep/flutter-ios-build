import 'package:cloud_firestore/cloud_firestore.dart';
import 'floor.dart';
import 'bigceiling.dart';
import 'wall.dart';

class Room {
  final String id;
  final String placeId;
  final String name;
  final List<Wall> walls;
  //final BigCeiling ceiling;
  //final Floor floor;

  Room({
    required this.id,
    required this.placeId,
    required this.name,
    required this.walls,
    //required this.ceiling,
    //required this.floor,
  });

  /// 🔹 Преобразуем объект `Room` в `Map<String, dynamic>` для Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': "${placeId}_$name", // ✅ Теперь есть `id`
      'placeId': placeId,
      'name': name,
      'walls': walls.map((w) => w.toMap()).toList(), // ✅ Добавили запятую
    };
  }

  // 'ceiling': ceiling.toMap(), // ✅ Теперь `ceiling` правильно сохраняется
  // 'floor': floor.toMap(), // ✅ Теперь `floor` правильно сохраняется

  /// 🔹 Создаём `Room` из Firestore
  factory Room.fromMap(Map<String, dynamic> data) {
    return Room(
      id: data['id'] ??
          "${data['placeId']}_room_${DateTime.now().millisecondsSinceEpoch}",
      placeId: data['placeId'] ?? '',
      name: data['name'] ?? '',
      walls: [], // Пока пусто, если стены не загружаются из Firestore
    );
  }

  /*    ceiling: data['ceiling'] != null
          ? BigCeiling.fromMap({
              ...data['ceiling'],
              'id': '${data['id']}_ceiling'
            } as Map<String, dynamic>)
          : BigCeiling(
              id: '${data['id']}_ceiling',
              width: 3.0,
              height: 2.5,
              elements: []), // ✅ Дефолтное значение

      floor: data['floor'] != null
          ? Floor.fromMap({...data['floor'], 'id': '${data['id']}_floor'}
              as Map<String, dynamic>)
          : Floor(
              id: '${data['id']}_floor',
              width: 3.0,
              height: 2.5,
              elements: []), // ✅ Дефолтное значение*/
}
