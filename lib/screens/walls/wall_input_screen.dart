import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/wall.dart';
import '/models/wall_element.dart';
import '/providers/wall_provider.dart';
import '/widgets/drawing/room_painter.dart';
import '/widgets/drawing/element_editor_dialog.dart';

Wall createMetaWall({
  required String placeId,
  required String roomId,
  required String title,
  required int floor,
  String? gptMeta,
}) {
  return Wall(
    id: "meta_${DateTime.now().millisecondsSinceEpoch}",
    order: 0,
    length: 0,
    height: 0,
    angle: 0,
    thickness: 0,
    direction: "inward",
    material: "метка",
    elements: [],
    params: {
      "название": title,
      "этаж": floor,
      "gptMeta": gptMeta ?? "",
      "тип": "инфо"
    },
  );
}

class WallInputScreen extends StatefulWidget {
  final String placeId;
  final String roomId;

  const WallInputScreen({
    Key? key,
    required this.placeId,
    required this.roomId,
  }) : super(key: key);

  @override
  State<WallInputScreen> createState() => _WallInputScreenState();
}

class _WallInputScreenState extends State<WallInputScreen> {
  List<Wall> _walls = [];

  final TextEditingController lengthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController angleController = TextEditingController();

  bool isOuterWall = true;

  bool get isLengthValid => double.tryParse(lengthController.text) != null;
  bool get isHeightValid => double.tryParse(heightController.text) != null;
  bool get isAngleValid => double.tryParse(angleController.text) != null;
  @override
  void initState() {
    super.initState();

    lengthController.text = '3.0';
    heightController.text = '2.5';
    angleController.text = '90';

    void _addWall() {
      final length = double.tryParse(lengthController.text) ?? 0;
      final height = double.tryParse(heightController.text) ?? 2.5;
      final angle = double.tryParse(angleController.text) ?? 90;

      if (length <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Введите длину > 0")),
        );
        return;
      }

      final wall = Wall(
        id: "wall_${DateTime.now().millisecondsSinceEpoch}",
        length: length,
        height: height,
        angle: angle,
        thickness: 0.2,
        direction: isOuterWall ? "inward" : "outward",
        material: "бетон",
        order: _walls.length + 1,
        elements: [], // тут будет важный момент!
      );

      setState(() {
        _walls.add(wall);
      });

      // Очистим поля
      //  lengthController.text = '3.0';
      //   heightController.text = '2.5';
      //   angleController.text = '90';
    }

    //   @override
    // void dispose() {
    //  lengthController.dispose();
    //   heightController.dispose();
    //  angleController.dispose();
    //   super.dispose();
    //   }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallProvider = Provider.of<WallProvider>(context, listen: false);
      wallProvider.loadWalls(widget.placeId, widget.roomId).then((_) {
        setState(() {
          _walls = wallProvider.walls;

          final hasMeta = _walls.any((w) => w.order == 0 && w.length == 0);
          if (!hasMeta) {
            final metaWall = createMetaWall(
              placeId: widget.placeId,
              roomId: widget.roomId,
              title: "Новая комната",
              floor: 1,
              gptMeta: "описание помещения",
            );
            _walls.insert(0, metaWall);
          }
        });
      });
    });
  }

  String _formatElement(WallElement e) {
    final type = e.type;
    final p = e.params;
    if (e.category == "строительный") {
      return "$type • ${p["ширина"] ?? "?"}×${p["высота"] ?? "?"} м • отступ: ${p["отступ"] ?? "?"} м";
    } else {
      return "$type • ${p["value"] ?? "?"} ${p["unit"] ?? ""}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallProvider = Provider.of<WallProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Редактор стен")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _walls.length,
              itemBuilder: (context, index) {
                final wall = _walls[index];

                if (wall.length == 0 && wall.order == 0) {
                  return ListTile(
                    title:
                        Text("📌 ${wall.params["название"] ?? "Мета-стена"}"),
                    subtitle:
                        Text("Информация: ${wall.params["gptMeta"] ?? "нет"}"),
                  );
                }

                return ListTile(
                  title: Text(
                      "Стена ${index + 1}: ${wall.length} м, угол ${wall.angle}°"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      ...wall.elements.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(_formatElement(e))),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      size: 20, color: Colors.blue),
                                  onPressed: () async {
                                    print("🔘 Кнопка нажата!");
                                    final updated =
                                        await showElementEditorDialog(
                                      context: context,
                                      wallId: wall.id,
                                      initial: e,
                                    );
                                    if (updated != null) {
                                      final index = wall.elements
                                          .indexWhere((el) => el.id == e.id);
                                      if (index != -1) {
                                        wall.elements[index] = updated;
                                        await wallProvider.updateElement(
                                          widget.placeId,
                                          widget.roomId,
                                          wall.id,
                                          updated,
                                        );
                                      }
                                      setState(() {});
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  tooltip: "Удалить",
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Удалить элемент?"),
                                        content: Text(
                                            "Вы уверены, что хотите удалить '${e.type}'?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Отмена"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Удалить"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      wall.elements
                                          .removeWhere((el) => el.id == e.id);
                                      await wallProvider.deleteElement(
                                        widget.placeId,
                                        widget.roomId,
                                        wall.id,
                                        e.id,
                                      );
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          )),
                      TextButton(
                        onPressed: () async {
                          print("Открываем диалог, selectedUnit");

                          final element = await showElementEditorDialog(
                            context: context,
                            wallId: wall.id,
                          );
                          if (element != null) {
                            wall.elements.add(element);
                            await wallProvider.addElementToWall(
                              widget.placeId,
                              widget.roomId,
                              wall.id,
                              element,
                            );
                            setState(() {});
                          }
                        },
                        child: const Text("+ Добавить элемент"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: CustomPaint(
              painter: RoomPainter(_walls, scale: 20),
              size: Size.infinite,
            ),
          ),
          // 🔹 2. Ввод новой стены
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Добавление стены",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "Длина стены (м)"),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "Высота стены (м)"),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: angleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Угол (°)"),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text("Стена внутрь (по часовой стрелке)"),
                  value: isOuterWall,
                  onChanged: (v) => setState(() => isOuterWall = v ?? true),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Добавить"),
                  onPressed: () {
                    print("Получен элемен");

                    if (!isLengthValid || !isHeightValid || !isAngleValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Проверьте значения перед добавлением")),
                      );
                      return;
                    }
                    double parseNum(dynamic value) {
                      if (value == null) return 0;
                      return double.tryParse(
                              value.toString().replaceAll(',', '.')) ??
                          0;
                    }

                    final angle = double.tryParse(angleController.text) ?? 0.0;
                    if (angle < 0 || angle > 360) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Угол должен быть от 0 до 360")),
                      );
                      return;
                    }

                    final wallProvider =
                        Provider.of<WallProvider>(context, listen: false);
                    final walls = wallProvider.walls;
                    final length = parseNum(lengthController.text);

                    Wall wall = Wall(
                      id: "wall_${walls.length + 1}",
                      length: double.tryParse(
                              lengthController.text.replaceAll(',', '.')) ??
                          6.0,
                      height: double.tryParse(
                              heightController.text.replaceAll(',', '.')) ??
                          2.5,
                      angle: angle,
                      thickness: 0.2,
                      direction: "default",
                      material: "бетон",
                      elements: [],
                      order: walls.length + 1, // 🔹 Установка точного номера
                    );

                    wallProvider.addWall(widget.placeId, widget.roomId, wall);
                    lengthController.clear();
                    heightController.clear();
                    angleController.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // 🔹 3. Кнопки "Удалить последнюю" и "Завершить и сохранить"
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_walls.length > 1) {
                      _walls.removeLast();
                      Provider.of<WallProvider>(context, listen: false)
                          .notifyListeners();
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text("Удалить последнюю"),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final wallProvider =
                        Provider.of<WallProvider>(context, listen: false);

                    for (var wall in _walls) {
                      // Пропускаем мета-стену (она уже добавлена)
                      if (wall.length == 0 && wall.order == 0) continue;

                      await wallProvider.addWall(
                        widget.placeId,
                        widget.roomId,
                        wall,
                      );
                    }

                    wallProvider.reset(); // сбрасываем провайдер
                    Navigator.pop(context); // возвращаемся назад
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("✔ Завершить и сохранить"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
