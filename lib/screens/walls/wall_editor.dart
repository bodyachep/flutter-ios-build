import 'package:flutter/material.dart';

import '/models/wall.dart';
import '/models/wall_element.dart';
//import '../elements/wall_element_editor.dart';

class WallEditor extends StatefulWidget {
  final Wall wall;
  final Function(Wall) onSave;

  const WallEditor({super.key, required this.wall, required this.onSave});

  @override
  WallEditorState createState() => WallEditorState();
}

class WallEditorState extends State<WallEditor> {
  late TextEditingController lengthController;
  late TextEditingController angleController;

  @override
  void initState() {
    super.initState();
    lengthController = TextEditingController(
      text: widget.wall.length.toString(),
    );
    angleController = TextEditingController(text: widget.wall.angle.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Редактировать стену"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: lengthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Длина (м)"),
          ),
          TextField(
            controller: angleController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Угол (°)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Отмена"),
        ),
        ElevatedButton(
          onPressed: () {
            double length =
                double.tryParse(lengthController.text) ?? widget.wall.length;
            double angle =
                double.tryParse(angleController.text) ?? widget.wall.angle;

            widget.onSave(
              Wall(
                id: widget.wall.id, // ✅ ID стены
                length: length,
                angle: angle,
                height: widget.wall.height,
                thickness: widget.wall.thickness,
                direction: widget.wall.direction,
                material: "beton", // ✅ Добавляем направление стены!
                elements: List.from(widget.wall.elements),
                order: widget.wall.order,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Сохранить"),
        ),
      ],
    );
  }
}
