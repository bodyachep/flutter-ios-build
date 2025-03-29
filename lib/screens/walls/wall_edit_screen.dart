import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../walls/wall_editor.dart';
import '/models/wall.dart';
import '/providers/wall_provider.dart';
import '/screens/objects/place_screen.dart';

class WallEditScreen extends StatefulWidget {
  final Wall wall;
  final String roomId; // Добавляем поле roomId
  final String placeId;

  const WallEditScreen({
    super.key,
    required this.wall,
    required this.roomId,
    required this.placeId,
  });

  @override
  WallEditScreenState createState() => WallEditScreenState();
}

class WallEditScreenState extends State<WallEditScreen> {
  late TextEditingController lengthController;
  late TextEditingController heightController;
  late TextEditingController angleController;
  late TextEditingController thicknessController;
  String selectedDirection = "inward" "outward";
  String selectedMaterial = "бетон"; // ✅ Дефолтное значение

  @override
  void initState() {
    super.initState();
    lengthController =
        TextEditingController(text: widget.wall.length.toString());
    heightController =
        TextEditingController(text: widget.wall.height.toString());
    angleController = TextEditingController(text: widget.wall.angle.toString());
    thicknessController =
        TextEditingController(text: widget.wall.thickness.toString());
    selectedDirection = widget.wall.direction;
    selectedMaterial = widget.wall.material; // ✅ Загружаем материал стены
  }

  @override
  void dispose() {
    lengthController.dispose();
    heightController.dispose();
    angleController.dispose();
    thicknessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallProvider = Provider.of<WallProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Редактирование стены")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: lengthController,
              decoration: const InputDecoration(labelText: "Длина (м)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: "Высота (м)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: angleController,
              decoration: const InputDecoration(labelText: "Угол (°)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: thicknessController,
              decoration: const InputDecoration(labelText: "Толщина (м)"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            // 🔹 Выбор направления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Направление:", style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: selectedDirection,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDirection = newValue!;
                    });
                  },
                  items: ["horizontal", "vertical"]
                      .map((dir) => DropdownMenuItem(
                            value: dir,
                            child: Text(dir),
                          ))
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Выбор материала
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Материал:", style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: selectedMaterial,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMaterial = newValue!;
                    });
                  },
                  items: ["бетон", "кирпич", "дерево", "металл"]
                      .map((mat) => DropdownMenuItem(
                            value: mat,
                            child: Text(mat),
                          ))
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final updatedWall = Wall(
                  id: widget.wall.id,
                  length: double.tryParse(lengthController.text) ??
                      widget.wall.length,
                  height: double.tryParse(heightController.text) ??
                      widget.wall.height,
                  angle: double.tryParse(angleController.text) ??
                      widget.wall.angle,
                  thickness: double.tryParse(thicknessController.text) ??
                      widget.wall.thickness,
                  direction: selectedDirection,
                  material: selectedMaterial,
                  order: widget.wall.order, // ✅ Теперь обновляем материал
                  elements: widget.wall.elements,
                );

                wallProvider.updateWall(
                    widget.placeId, widget.roomId, updatedWall.id, updatedWall);
                Navigator.pop(context);
              },
              child: const Text("💾 Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}
