import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/place_provider.dart';
import '/providers/wall_provider.dart';
import '/providers/room_provider.dart';
import 'place_screen.dart';

import '/models/place.dart'; // Import the Place model

void _showAddPlaceDialog(BuildContext context) {
  TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Добавить помещение"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: "Введите название"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ Отмена
            child: Text("Отмена"),
          ),
          TextButton(
            onPressed: () {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Provider.of<PlaceProvider>(context, listen: false)
                    .addPlace(newName); // ✅ Передаём введённое имя
                Navigator.pop(context);
              }
            },
            child: Text("Добавить"),
          ),
        ],
      );
    },
  );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadPlacesFuture;

  @override
  void initState() {
    super.initState();
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
    _loadPlacesFuture = placeProvider.loadPlaces(); // ✅ Загружаем один раз
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = Provider.of<PlaceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Список помещений")),
      body: FutureBuilder(
        future: _loadPlacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Place> places = placeProvider.places;

          return places.isEmpty
              ? const Center(child: Text("Нет доступных помещений"))
              : ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return ListTile(
                      title: Text(place.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Provider.of<PlaceProvider>(context, listen: false)
                              .removePlace(place.id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceScreen(
                                placeId: place.id,
                                roomId: place.roomId ?? 'default_room'),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPlaceDialog(
              context); // ✅ Вызываем диалог вместо "Новое помещение"
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
