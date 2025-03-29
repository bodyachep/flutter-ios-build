import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/screens/objects/place_screen.dart';

class RoomInputScreen extends StatefulWidget {
  final String placeId;
  final String? roomName; // ✅ Добавляем roomName

  const RoomInputScreen({super.key, required this.placeId, this.roomName});

  @override
  _RoomInputScreenState createState() => _RoomInputScreenState();
}

class _RoomInputScreenState extends State<RoomInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Введите название комнаты")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Название комнаты"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String roomName = _nameController.text.trim();
                if (roomName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Введите название комнаты")),
                  );
                  return;
                }
                Navigator.pop(context, roomName); // ✅ Возвращаем только имя!
              },
              child: const Text("Далее → Ввод размеров"),
            ),
          ],
        ),
      ),
    );
  }
}
