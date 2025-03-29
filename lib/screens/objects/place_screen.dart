import 'package:flutter/material.dart';
import '/models/place.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/wall.dart'; // ✅ Импортируем класс Wall

import 'dart:async';
import '/providers/room_provider.dart';
import '/screens/walls/wall_input_screen.dart';
import '/providers/wall_provider.dart';

import '../rooms/room_screen.dart';
import 'home_screen.dart';
import '/screens/rooms/room_screen.dart';
import '/screens/rooms/room_input_screen.dart';
import '/screens/rooms/room_detail_screen.dart';
import '../walls/wall_edit_screen.dart';

class PlaceScreen extends StatefulWidget {
  final String placeId;
  // final String wallId; // ✅ Должен быть!
  final String? roomId; // ✅ Добавляем roomId

  const PlaceScreen({
    super.key,
    required this.placeId,
    this.roomId,
  });
  @override
  PlaceScreenState createState() => PlaceScreenState();
}

class PlaceScreenState extends State<PlaceScreen> {
  List<Map<String, dynamic>> _rooms = [];
  List<Wall> walls = []; // ✅ Добавляем `walls`
  String newRoomName = ''; // Добавляем переменную здесь
  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  /// 🔹 Загружаем комнаты из Firestore

  Future<void> _loadRooms() async {
    var snapshots = await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .collection('rooms')
        .get();
    if (!mounted) return; // ✅ Проверяем, не был ли экран закрыт

    setState(() {
      _rooms = snapshots.docs.map((doc) {
        var data = doc.data();
        if (data == null)
          return <String, dynamic>{}; // ✅ Теперь это точно Map<String, dynamic>

        var fixedData = data as Map<String, dynamic>;
        fixedData['id'] = doc.id;
        return fixedData;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Помещение")),
      body: _rooms.isEmpty
          ? const Center(child: Text("Нет комнат. Нажмите + для добавления."))
          : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return ListTile(
                  title: Text(room['name'] ?? 'Без названия'),
                  onTap: () {
                    print("🏠 Открываем комнату: ${room['id']}"); // ✅ Проверка

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailsScreen(
                          placeId: widget.placeId,
                          roomId: room['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 🔹 1. Вводим название комнаты

          final roomName = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomInputScreen(placeId: widget.placeId),
            ),
          );

          if (roomName == null || roomName.isEmpty) return;

          // // 🔹 2. Создаём комнату
          final newRoomId =
              await Provider.of<RoomProvider>(context, listen: false)
                  .addRoom(widget.placeId, roomName);
          print("✅ Создана новая комната с ID: $newRoomId");

          // 🔹 3. Открываем редактор стен
          final List<Wall>? newWalls = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WallInputScreen(
                placeId: widget.placeId,

                roomId: newRoomId,

                //    roomName: roomName,
                //   wallId:
                //     "wall_${DateTime.now().millisecondsSinceEpoch}", // ✅ Теперь `wallId` передаётся
                //    initialWalls: [],
              ),
            ),
          );

          // ❌ Если стены не добавлены – не создаём комнатуP
          if (newWalls == null || newWalls.isEmpty) return;

          // 🔹 4. Сохраняем стены в Firestore
          final wallProvider =
              Provider.of<WallProvider>(context, listen: false);
          for (var wall in newWalls) {
            await wallProvider.addWall(widget.placeId, newRoomId, wall);
            print('🏁 Переход в WallInputScreen | roomId=$newRoomId');
          }

          // 🔹 5. Открываем RoomDetailsScreen с чертежом
          if (context.mounted) {
            print(
                "🚀 Открываем RoomDetailsScreen: placeId=${widget.placeId}, roomId=$newRoomId");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RoomDetailsScreen(
                  placeId: widget.placeId,
                  roomId: newRoomId,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
