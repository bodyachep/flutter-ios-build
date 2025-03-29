import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/room_provider.dart';
import '/providers/wall_provider.dart';
import '/models/room.dart';
import '/screens/walls/wall_input_screen.dart';
import '/screens/rooms/room_input_screen.dart';
import '/models/wall.dart';
import '/screens/rooms/room_detail_screen.dart';

class RoomEditScreen extends StatefulWidget {
  final String placeId;
  final String roomId;

  const RoomEditScreen(
      {super.key, required this.placeId, required this.roomId});

  @override
  State<RoomEditScreen> createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends State<RoomEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ceilingHeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Здесь можно загрузить данные комнаты и заполнить контроллеры

    // Пример: автозаполнение полей для редактирования
    // Здесь можно получить room из RoomProvider или Firestore
    nameController.text = "Пример комнаты";
    ceilingHeightController.text = "2.8";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактировать комнату")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Название комнаты"),
            ),
            TextField(
              controller: ceilingHeightController,
              decoration: const InputDecoration(labelText: "Высота потолков"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: сохранить данные
                ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final newHeight =
                        double.tryParse(ceilingHeightController.text.trim());

                    if (newName.isEmpty || newHeight == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Заполните все поля корректно")),
                      );
                      return;
                    }

                    await Provider.of<RoomProvider>(context, listen: false)
                        .updateRoom(
                      widget.placeId,
                      widget.roomId,
                      {
                        'name': newName,
                        'ceilingHeight': newHeight,
                      },
                    );

                    print("💾 Обновлено в Firestore: $newName, $newHeight м");
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("Сохранить"),
                );

                print(
                    "💾 Сохраняем: ${nameController.text}, ${ceilingHeightController.text} м");
                Navigator.pop(context);
                // Тут будет логика сохранения
              },
              child: const Text("Сохранить"),
            )
          ],
        ),
      ),
    );
  }
}
