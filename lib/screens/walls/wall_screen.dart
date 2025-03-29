import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/wall_provider.dart';
import '../elements/wall_details_screen.dart';
import 'wall_edit_screen.dart';

class WallScreen extends StatelessWidget {
  final String roomId; // ✅ Добавили поле roomId
  final String placeId;
  const WallScreen({super.key, required this.placeId, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final wallProvider = Provider.of<WallProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Список стен")),
      body: ListView.builder(
        itemCount: wallProvider.walls.length,
        itemBuilder: (context, index) {
          final wall = wallProvider.walls[index];
          return ListTile(
            title: Text("Стена ${index + 1}: ${wall.length} м"),
            subtitle: Text("Высота: ${wall.height} м, Угол: ${wall.angle}°"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WallEditScreen(
                    placeId: placeId, wall: wall,
                    roomId: roomId, // добавляем roomId
                  ),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline), // 🔥 Кнопка "Детали"
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WallDetailsScreen(wall: wall),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () =>
                      wallProvider.removeWall(placeId, roomId, wall.id),
                ),
              ],
            ),
          ); // ✅ Закрыли ListTile
        },
      ), // ✅ Закрыли ListView.builder
    ); // ✅ Закрыли Scaffold
  } // ✅ Закрыли build()
} // ✅ Закрыли класс WallScreen
