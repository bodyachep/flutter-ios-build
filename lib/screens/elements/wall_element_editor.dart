/* import 'package:flutter/material.dart';

import '/models/wall_element.dart';

class WallElementEditor extends StatefulWidget {
  final List<WallElement> elements;
  final Function(List<WallElement>)
      onElementsUpdated; // ✅ Колбэк для обновления

  const WallElementEditor({
    super.key,
    required this.elements,
    required this.onElementsUpdated,
  });

  @override
  _WallElementEditorState createState() => _WallElementEditorState();
}

class _WallElementEditorState extends State<WallElementEditor> {
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController depthController = TextEditingController();
  final TextEditingController offsetController = TextEditingController();

  String selectedType = "window"; // По умолчанию
  String selectedUnit = "шт"; // ✅ По умолчанию "шт"
  void _saveElement() {
    double width = double.tryParse(widthController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;
    double x = double.tryParse(depthController.text) ?? 0.0;
    double y = double.tryParse(offsetController.text) ?? 0.0;

    if (width <= 0 || height <= 0) return;

    setState(() {
      widget.elements.add(WallElement(
        id: "we_${DateTime.now().millisecondsSinceEpoch}", // ✅ Теперь это работает

        type: selectedType,
        width: width,
        height: height,
        depth: 0.0, // ✅ Глубина
        offset: 0.0, // ✅ От стены
        unit: selectedUnit, // ✅ Сохраняем "шт" или "м/п"
      ));
    });

    widget.onElementsUpdated(widget.elements); // ✅ Сообщаем об обновлении
    Navigator.pop(context); // Закрываем окно
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Добавить элемент",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: selectedType,
            onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue!;
              });
            },
            items: const [
              DropdownMenuItem(value: "window", child: Text("🏠 Окно")),
              DropdownMenuItem(value: "door", child: Text("🚪 Дверь")),
              DropdownMenuItem(value: "other", child: Text("🎨 Другое")),
            ],
          ),
          TextField(
              controller: widthController,
              decoration: const InputDecoration(labelText: "Ширина (м)")),
          TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: "Высота (м)")),
          TextField(
            controller: depthController,
            decoration: InputDecoration(labelText: "Позиция глубина (м)"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: offsetController,
            decoration: InputDecoration(labelText: "Позиция от угла (м)"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _saveElement,
                icon: const Icon(Icons.check),
                label: const Text("Добавить"),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text("Отмена"),
              ),
            ],
          ),
        ],
      ),
    );
  }
} */
