import 'package:cloud_firestore/cloud_firestore.dart';
import '/providers/room_provider.dart';
import 'place.dart';
import 'bigelement.dart'; // ✅ Импорт BigElement
import 'wall.dart';
import 'floor.dart';
import 'room.dart';
import '/models/bigceiling.dart';
import '/models/bigelement.dart';
import '/models/floor.dart';
import '/models/place.dart';
import '/models/room.dart';
import '/models/wall_element.dart';
import '/models/wall.dart';
import '/models/bigceiling.dart';
import '/providers/place_provider.dart';
//import '/providers/project_provider.dart';
import '/providers/room_provider.dart';

import '/providers/wall_provider.dart';

import '/screens/elements/ceiling_edit_screen.dart';
import '/screens/elements/wall_details_screen.dart';
import '/screens/elements/wall_element_editor.dart';
import '/screens/rooms/floor_edit_screen.dart';
import '/screens/rooms/room_editor.dart';
import '/screens/rooms/room_input_screen.dart';
import '/screens/rooms/room_screen.dart';
import '/screens/walls/wall_edit_screen.dart';
import '/screens/walls/wall_editor.dart';
import '/screens/walls/wall_input_screen.dart';
import '/screens/walls/wall_screen.dart';
import '/widgets/drawing/room_painter.dart';
import '/widgets/lists/wall_list.dart';

class BigCeiling {
  String id;
  double width;
  double height;
  List<BigElement> elements;

  BigCeiling({
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

  /// 🔹 Создание объекта `BigCeiling` из Firestore
  factory BigCeiling.fromMap(Map<String, dynamic> map) {
    return BigCeiling(
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
