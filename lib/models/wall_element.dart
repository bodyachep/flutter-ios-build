import 'bigelement.dart';

class WallElement {
  String id;
  String category; // инженерия / отделка / повреждение / другое
  String type; // розетка / кабель / плинтус / дырка / плитка / и т.д.
  Map<String, dynamic> params; // гибкие параметры под конкретный тип

  WallElement({
    required this.id,
    required this.category,
    required this.type,
    required this.params,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'params': params,
    };
  }

  factory WallElement.fromMap(Map<String, dynamic> map) {
    return WallElement(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      params: Map<String, dynamic>.from(map['params'] ?? {}),
    );
  }
}
