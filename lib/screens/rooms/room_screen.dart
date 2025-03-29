import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/room_provider.dart';
import '/providers/wall_provider.dart';
import '/models/room.dart';
import '/screens/walls/wall_input_screen.dart';
import '/screens/rooms/room_input_screen.dart';
import '/models/wall.dart';
import '/screens/rooms/room_detail_screen.dart';

class RoomScreen extends StatefulWidget {
  final String placeId;
  final String? roomId;

  const RoomScreen({super.key, required this.placeId, this.roomId});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<RoomProvider>(context, listen: false).loadRooms(widget.placeId);
  }
  // ✅ Вот здесь метод _showRoomInputScreen()

  // ✅ Вот здесь метод _showRoomInputScreen()
  Future<String?> _showRoomInputScreen() async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomInputScreen(placeId: widget.placeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    //  final wallProvider = Provider.of<WallProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (roomProvider.rooms.isNotEmpty) {
        print("🚀 Открываем комнату: ${roomProvider.rooms.first.id}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(
              placeId: widget.placeId,
              roomId: roomProvider.rooms.last.id, // ✅ Передаём реальный ID
            ),
          ),
        );
      } else {
        print("⏳ Ждём загрузки комнат...");
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Комнаты")),
      body: roomProvider.rooms.isEmpty
          ? const Center(child: Text("Нет комнат"))
          : ListView.builder(
              itemCount: roomProvider.rooms.length,
              itemBuilder: (context, index) {
                final room = roomProvider.rooms[index];
                return ListTile(
                  title: Text(room.name),
                  onTap: () {
                    print("📌 Открываем комнату: ${room.id} в ${room.placeId}");
                    print(
                        '➡ Переход в RoomDetailsScreen | передаём roomId=${room.id}');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailsScreen(
                          placeId: room.placeId, // ✅ Передаём placeId
                          roomId: room.id, // ✅ Передаём roomId
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final roomName = await _showRoomInputScreen();
          if (roomName == null || roomName.isEmpty) return;

          // Дальше код добавления комнаты
        },
        child: const Icon(Icons.add),
        tooltip: "Добавить комнату",
      ),
    );
  }
}
