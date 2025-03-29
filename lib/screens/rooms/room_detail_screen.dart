import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_project/screens/rooms/room_edit_screen.dart';

import '/providers/room_provider.dart';
import '/providers/wall_provider.dart';
import '/models/room.dart';
import '/screens/walls/wall_input_screen.dart';
import '/screens/rooms/room_input_screen.dart';
import '/models/wall.dart';
import '/models/bigceiling.dart';
import '/screens/rooms/room_screen.dart';
import '/widgets/drawing/room_painter.dart';

class RoomDetailsScreen extends StatefulWidget {
  // ✅ Делаем StatefulWidget
  final String placeId;
  final String roomId;

  const RoomDetailsScreen(
      {super.key, required this.placeId, required this.roomId});

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late Future<Room?> roomDataFuture; // ✅ Создаём Future

  @override
  void initState() {
    super.initState();

    // Загружаем данные комнаты как и раньше
    roomDataFuture = Provider.of<RoomProvider>(context, listen: false)
        .loadRoom(widget.placeId, widget.roomId);

    // Загружаем стены уже ПОСЛЕ первого кадра UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallProvider = Provider.of<WallProvider>(context, listen: false);

      wallProvider.reset();
      wallProvider.loadWalls(widget.placeId, widget.roomId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallProvider = Provider.of<WallProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Комната: ${widget.roomId}"),
        //22.03     actions: [
        //22.03       IconButton(
        //22.03         icon: Icon(Icons.edit),
        //22.03        onPressed: () {
        //22.03           Navigator.push(
        //22.03            context,
        //22.03             MaterialPageRoute(
        //22.03               builder: (_) => RoomEditScreen(
        //22.03
        ////22.03                  placeId: widget.placeId,
        //22.03                roomId: widget.roomId,
        //22.03                 ),
      ),
      //22.03           );
      //22.03          },
      //22.03        )
      //22.03      ],
      //22.03    ),
      body: FutureBuilder<Room?>(
        future: roomDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Ошибка загрузки комнаты"));
          }

          final room = snapshot.data!;
          return Column(
            children: [
              ListTile(title: Text("Название: ${room.name}")),

              //   ListTile(title: Text("Высота потолков: ${room.ceiling?.height ?? "не указано"} м")),
              Expanded(
                child: CustomPaint(
                  painter: RoomPainter(wallProvider.walls, scale: 20),
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                label: Text("Удалить комнату"),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Удалить комнату?"),
                        content: Text(
                            "Вы уверены, что хотите удалить эту комнату и все её стены?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Отмена"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Удалить",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    await Provider.of<RoomProvider>(context, listen: false)
                        .removeRoom(widget.placeId, widget.roomId);

                    if (mounted) {
                      Navigator.pop(
                          context); // Возвращаемся назад после удаления
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
