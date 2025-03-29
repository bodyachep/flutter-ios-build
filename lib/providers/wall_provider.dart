import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/wall.dart';
import '../models/wall_element.dart';
import '/screens/rooms/room_detail_screen.dart';

class WallProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Wall> _walls = [];
  List<Wall> get walls => _walls;

  void reset() {
    _walls = [];
    notifyListeners();
  }

  // LOAD с очисткой перед загрузкой
  Future<void> loadWalls(String placeId, String roomId) async {
    reset(); // << очищаем список стен перед загрузкой
    if (_walls.isNotEmpty) {
      print("✅ Стены уже загружены, повторная загрузка не нужна!");
      return; // 🔹 Если стены уже есть, не загружаем их снова
    }
    var snapshot = await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .get();
    List<Wall> loadedWalls = [];
    for (var doc in snapshot.docs) {
      var wall = Wall.fromMap(doc.data());
      // 🔹 Загружаем элементы вместе со стеной
      var elementSnapshot = await _firestore
          .collection("places")
          .doc(placeId)
          .collection("rooms")
          .doc(roomId)
          .collection("walls")
          .doc(wall.id)
          .collection("elements")
          .get();
      // ✅ Важно: переместили сюда
      final elements = elementSnapshot.docs
          .map((doc) => WallElement.fromMap(doc.data()))
          .toList();
      loadedWalls.add(Wall(
        id: wall.id,
        length: wall.length,
        height: wall.height,
        angle: wall.angle,
        thickness: wall.thickness,
        direction: wall.direction,
        material: wall.material,
        order: wall.order,
        elements: elements, // ✅ теперь переменная доступна
      ));
    }
    _walls = loadedWalls;
    notifyListeners(); // ✅ Обновляем только один раз после загрузки всех данных
    print("✅ Загружено стен: ${_walls.length}");
  }

  /// 🔹 Добавляем новую стену
  Future<void> addWall(String placeId, String roomId, Wall wall) async {
    var newWallRef = _firestore
        .collection("places") // ✅ Теперь стена сохраняется в правильном месте
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .doc(wall.id); // <-- передаём свой ID
    await newWallRef.set(wall.toMap());
    _walls.add(Wall(
      id: newWallRef.id,
      length: wall.length,
      height: wall.height,
      angle: wall.angle,
      thickness: wall.thickness,
      direction: wall.direction,
      material: wall.material,
      elements: wall.elements,
      order: wall.order, // ✅ вот это добавляем
    ));
    notifyListeners();
  }

  Future<void> addElementToWall(
    String placeId,
    String roomId,
    String wallId,
    WallElement element,
  ) async {
    final wall = _walls.firstWhere((w) => w.id == wallId);

    // 🔒 Проверка по ID и содержимому (на всякий случай)
    final alreadyExists = wall.elements.any((e) =>
        e.id == element.id ||
        (e.type == element.type &&
            e.params.toString() == element.params.toString()));

    if (alreadyExists) {
      print("⚠️ Элемент уже существует, не сохраняем дубликат");
      return;
    }
    wall.elements.add(element);
    await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .doc(wallId)
        .collection("elements")
        .doc(element.id) // ✅ фиксированный ID
        .set(element.toMap());

    notifyListeners();
  }

  /// 🔹 Обновляем существующую стену
  Future<void> updateWall(
      String placeId, String roomId, String wallId, Wall updatedWall) async {
    await _firestore
        .collection("places") // ✅ Теперь обновляем стену по правильному пути
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .doc(wallId)
        .update(updatedWall.toMap());

    int index = _walls.indexWhere((w) => w.id == wallId);
    if (index != -1) {
      _walls[index] = updatedWall;
      notifyListeners();
    }
  }

  /// 🔹 Удаляем стену
  Future<void> removeWall(String placeId, String roomId, String wallId) async {
    await _firestore
        .collection("places") // ✅ Теперь удаляем из правильного пути
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .doc(wallId)
        .delete();

    _walls.removeWhere((wall) => wall.id == wallId);
    notifyListeners();
  }

  void loadInitialWalls(List<Wall> walls) {
    _walls = walls;
    notifyListeners();
  }

  Future<void> deleteElement(
    String placeId,
    String roomId,
    String wallId,
    String elementId,
  ) async {
    await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .doc(wallId)
        .collection("elements")
        .doc(elementId)
        .delete();
  }

  Future<void> updateElement(
      String placeId, String roomId, String wallId, WallElement element) async {
    await _firestore
        .collection("places")
        .doc(placeId)
        .collection("rooms")
        .doc(roomId)
        .collection("walls")
        .doc(wallId)
        .collection("elements")
        .doc(element.id)
        .set(element.toMap()); // перезапись
  }
}
