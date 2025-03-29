import 'bigelement.dart';

class Floor {
  String id;
  double width;
  double height;
  List<BigElement> elements;

  Floor({
    required this.id,
    required this.width,
    required this.height,
    required this.elements,
  });

  /// 🔹 Преобразование в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'elements': elements.map((e) => e.toMap()).toList(),
    };
  }

  /// 🔹 Создание объекта `Floor` из Firestore
  factory Floor.fromMap(Map<String, dynamic> map) {
    return Floor(
      id: map['id'] ?? '',
      width: (map['width'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      elements: (map['elements'] as List<dynamic>?)
              ?.map((e) => BigElement.fromMap(
                  e as Map<String, dynamic>)) // ✅ Безопасная конвертация
              .toList() ??
          [],
    );
  }
}
