import 'package:cloud_firestore/cloud_firestore.dart';

import 'bigelement.dart';
import '/screens/rooms/room_input_screen.dart';
import '/screens/walls/wall_editor.dart';
import '/screens/walls/wall_edit_screen.dart';
import '/screens/walls/wall_input_screen.dart';
import 'wall_element.dart';
import '/widgets/drawing/element_editor_dialog.dart';

class Wall {
  final String id;
  final double length;
  final double height;
  final double angle;
  final double thickness;
  final String direction;
  final String material;
  final List<WallElement> elements;
  final int order; // 🔹 новое поле
  Map<String, dynamic> params; // ✅ Добавляем params
  Wall({
    required this.id,
    required this.length,
    required this.height,
    required this.angle,
    required this.thickness,
    required this.direction,
    required this.material,
    required this.elements,
    required this.order, // 🔹 и здесь
    this.params = const {}, // ✅
  });

  factory Wall.fromMap(Map<String, dynamic> map) {
    return Wall(
      id: map['id'] ?? '',
      length: (map['length'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      angle: (map['angle'] ?? 0).toDouble(),
      thickness: (map['thickness'] ?? 0).toDouble(),
      direction: map['direction'] ?? 'default',
      material: map['material'] ?? 'бетон',
      elements: [], // <-- загружается отдельно
      order: map['order'] ?? 0, // 🔹 сюда
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'length': length,
      'height': height,
      'angle': angle,
      'thickness': thickness,
      'direction': direction,
      'material': material,
      'order': order, // 🔹 обязательно
      'elements': elements,
    };
  }
}
