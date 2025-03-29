import 'package:flutter/material.dart';

import '/models/wall.dart';

import '/widgets/lists/wall_list.dart';
import '../walls/wall_editor.dart'; // ✅ Исправили импорт

class RoomEditor extends StatefulWidget {
  final String roomId;
  final String placeId; // 📌 Теперь знаем, к какому помещению относится
  final List<Wall> walls; // 📌 Добавляем стены
  final Function(List<Wall>) onWallsUpdated;

  const RoomEditor({
    super.key,
    required this.roomId,
    required this.placeId,
    required this.walls,
    required this.onWallsUpdated,
  });

  @override
  RoomEditorState createState() => RoomEditorState();
}

class RoomEditorState extends State<RoomEditor> {
  @override
  Widget build(BuildContext context) {
    print("walls в RoomEditor: ${widget.walls}"); // ✅ Проверяем, дошли ли стены
    print("🛑 `addRoom()` вызывается в `initState()`!");

    return Column(
      children: [
        Expanded(
          child: WallList(
            walls: widget.walls,
            onEdit: (index) => _editWall(index), // ✅ Передаём onEdit
            onElementsUpdated: _updateWalls, // ✅ Обновляем список стен
          ),
        ),
      ],
    );
  }

  void _editWall(int index) {
    showDialog(
      context: context,
      builder: (context) => WallEditor(
        wall: widget.walls[index], // ✅ Передаём только одну стену
        onSave: (updatedWall) {
          _updateWall(index, updatedWall); // ✅ Обновляем одну стену
        },
      ),
    );
  }

  void _updateWalls(List<Wall> updatedWalls) {
    setState(() {
      widget.onWallsUpdated(updatedWalls); // ✅ Передаём изменения в RoomScreen
    });
  }

  void _updateWall(int index, Wall updatedWall) {
    List<Wall> updatedWalls = List.from(widget.walls);
    updatedWalls[index] = updatedWall;
    _updateWalls(updatedWalls); // ✅ Передаём обновления через _updateWalls
  }
}
