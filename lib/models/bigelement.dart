import 'package:cloud_firestore/cloud_firestore.dart';
import 'wall_element.dart';

class BigElement {
  String id;
  String type; // Тип элемента (например, "окно", "дверь")
  double width;
  double height;

  BigElement({
    required this.id,
    required this.type,
    required this.width,
    required this.height,
  });

  /// 🔹 Преобразование в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'width': width,
      'height': height,
    };
  }

  /// 🔹 Создание объекта `BigElement` из Firestore
  factory BigElement.fromMap(Map<String, dynamic> map) {
    return BigElement(
      id: map['id'] ?? '',
      type: map['type'] ?? 'unknown',
      width: (map['width'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
    );
  }
}
