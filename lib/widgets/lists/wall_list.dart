import 'package:flutter/material.dart';
import '/models/floor.dart';
import '/models/wall.dart';
import '/providers/room_provider.dart';

import '/providers/wall_provider.dart';

class WallList extends StatelessWidget {
  final List<Wall> walls;
  final Function(int) onEdit;
  final Function(List<Wall>) onElementsUpdated; // ✅ Теперь передаём `walls`!

  const WallList({
    super.key,
    required this.walls,
    required this.onEdit,
    required this.onElementsUpdated, // ✅ Теперь передаём обновлённые стены
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: walls.length,
      itemBuilder: (context, index) {
        Wall wall = walls[index];
        return ListTile(
          title: Text("Стена ${index + 1}"),
          subtitle: Text("Длина: ${wall.length} м, Угол: ${wall.angle}°"),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(index), // ✅ Редактируем стену
          ),
        );
      },
    );
  }
}
