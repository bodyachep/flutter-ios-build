import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/wall.dart';
import '../screens/walls/wall_input_screen.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Room> _rooms = [];

  List<Room> get rooms => _rooms;

  // final Set<String> _loadedRooms =
  //     {}; // ✅ Добавляем Set для проверки загруженных комнат
  /// Устанавливаем активную комнату
//  void setActiveRoom(Room room) {

  //  notifyListeners();
  // }

  //void clearActiveRoom() {

  // notifyListeners();
  // }

  /// 🔹 Загружаем все комнаты для помещения
  Future<void> loadRooms(String placeId) async {
    var snapshot = await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .get();

    _rooms = snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id; // ✅ Добавляем `id`
      return Room.fromMap(data);
    }).toList();
// 🔥 Выводим данные каждой комнаты
    for (var room in _rooms) {
      print(
          "📄 Комната: ID=${room.id}, Name=${room.name}, Place=${room.placeId}");
    }
    notifyListeners();
  }

  Future<Room?> loadRoom(String placeId, String roomId) async {
    print(
        "📡 Загружаем комнату из Firestore: placeId=$placeId, roomId=$roomId");
    var doc = await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .get();

    if (!doc.exists) {
      print("❌ Комната $roomId не найдена в $placeId!");
      return null;
    }

    var room = Room.fromMap(doc.data()!);
    // Обновляем локальный список _rooms
    int index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = room;
    } else {
      _rooms.add(room);
    }

    notifyListeners();
    print("✅ Комната загружена: ID=${room.id}, Name=${room.name}");
    return room;
  }

  /// 🔹 Добавляем новую комнату
  Future<String> addRoom(String placeId, String roomName) async {
    try {
      // 🔹 Обрабатываем название комнаты в ID
      String roomId = roomName
          .trim()
          .replaceAll(
              RegExp(r'[^\wа-яА-ЯёЁ0-9-]'), '') // Удаляем запрещённые символы
          .replaceAll(' ', '_') // Пробелы → "_"
          .toLowerCase();
      print("📡 Создаём комнату: placeId=$placeId, roomId=$roomId");

      // 🔹 Если ID пустой, создаём уникальный резервный ID
      if (roomId.isEmpty) {
        roomId = "room_${DateTime.now().millisecondsSinceEpoch}";
      }

      // 🔹 Проверяем, существует ли уже такая комната
      var existingRoom = await _firestore
          .collection("places")
          .doc(placeId)
          .collection("rooms")
          .doc(roomId)
          .get();

      if (existingRoom.exists) {
        print("⚠️ Комната с ID $roomId уже существует!");
        return roomId; // ✅ Возвращаем уже существующий ID
      }

      // 🔹 Создаём объект комнаты
      final newRoom = Room(
        id: roomId,
        placeId: placeId,
        name: roomName,
        walls: [],
      );

      // 🔹 Сохраняем комнату в Firestore
      await _firestore
          .collection("places")
          .doc(placeId)
          .collection("rooms")
          .doc(roomId)
          .set(newRoom.toMap());

      _rooms.add(newRoom);
      notifyListeners();

      print("✅ Комната сохранена: $roomName (ID: $roomId)");
      return roomId;
    } catch (e) {
      print("🔥 Ошибка при добавлении комнаты: $e");
      return Future.error(
          "Ошибка при добавлении комнаты: $e"); // ✅ Теперь ошибка передаётся корректно
    }
  }

  /// 🔹 Удаляем комнату и её стены
  Future<void> removeRoom(String placeId, String roomId) async {
    // Удаляем все стены этой комнаты
    var wallRefs = await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .get();

    for (var doc in wallRefs.docs) {
      await doc.reference.delete();
    }

    // Удаляем саму комнату
    await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .delete();

    _rooms.removeWhere((room) => room.id == roomId);
    notifyListeners();
    print("🗑 Комната $roomId удалена вместе со стенами.");
  }

  Future<void> updateRoom(
      String placeId, String roomId, Map<String, dynamic> updates) async {
    await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .update(updates);

    int index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = Room(
        id: roomId,
        placeId: placeId,
        name: updates['name'] ?? _rooms[index].name,
        walls: _rooms[index].walls,
      );
      notifyListeners();
    }
  }
}
