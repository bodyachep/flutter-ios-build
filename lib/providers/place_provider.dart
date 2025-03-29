import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

class PlaceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Place> _places = [];

  List<Place> get places => _places;

  /// 🔹 Удаляем место
  Future<void> removePlace(String placeId) async {
    try {
      await _firestore.collection("places").doc(placeId).delete();
      _places.removeWhere((place) => place.id == placeId);
      notifyListeners();
    } catch (e) {
      print("🔥 Ошибка при удалении места: $e");
    }
  }

  /// 🔹 Загружаем список мест из Firestore
  Future<void> loadPlaces() async {
    try {
      var snapshot = await _firestore.collection('places').get();
      _places = snapshot.docs
          .map((doc) => Place.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print("🔥 Ошибка загрузки мест: $e");
    }
  }

  Future<void> addPlace(String name) async {
    try {
      // ✅ Очищаем название от лишних пробелов
      String placeId = name.trim().replaceAll(' ', '_');

      // 🔹 Firestore не принимает пустые ID, подстрахуемся
      if (placeId.isEmpty) {
        throw Exception("Название не может быть пустым!");
      }

      // ✅ Добавляем место в Firestore с таким же ID, как название
      await _firestore.collection("places").doc(placeId).set({"name": name});

      var newPlace = Place(id: placeId, name: name);
      _places.add(newPlace);
      notifyListeners();
    } catch (e) {
      print("🔥 Ошибка при добавлении места: $e");
    }
  }
}
