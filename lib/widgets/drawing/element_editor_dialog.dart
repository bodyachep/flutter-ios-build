import 'package:flutter/material.dart';
import '/models/wall_element.dart';
import '/providers/wall_provider.dart';
import '/models/wall.dart';
import '/screens/walls/wall_input_screen.dart';

Future<WallElement?> showElementEditorDialog({
  required BuildContext context,
  required String wallId,
  WallElement? initial,
}) {
  final isEdit = initial != null;
  String mode =
      initial?.category == "Стандартный" ? "Строительный" : "Универсальный";
  String selectedType = initial?.type ?? "окно";
  String selectedUnit = initial?.params["unit"] ?? "шт";
  String customName = initial?.type ?? "";

  final controllers = {
    "ширина": TextEditingController(text: "${initial?.params["ширина"] ?? ""}"),
    "высота": TextEditingController(text: "${initial?.params["высота"] ?? ""}"),
    "отступ": TextEditingController(text: "${initial?.params["отступ"] ?? ""}"),
    "floorOffset":
        TextEditingController(text: "${initial?.params["floorOffset"] ?? ""}"),
    "ceilingOffset":
        TextEditingController(text: "${initial?.params["от потолка"] ?? ""}"),
    "value": TextEditingController(text: "${initial?.params["value"] ?? ""}"),
  };
  final unitOptions = ["шт", "м/п", "м²"];
  if (!unitOptions.contains(selectedUnit)) {
    selectedUnit = unitOptions.first;
  }
  double _parse(String input) =>
      double.tryParse(input.replaceAll(",", ".")) ?? 0.0;

  return showDialog<WallElement>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add),
            const SizedBox(width: 8),
            Text(isEdit ? "Редактировать элемент" : "Добавить элемент в стену"),
          ],
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text("Режим: "),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: mode,
                      items: ["Стандартный", "Универсальный"]
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => mode = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (mode == "Стандартный") ...[
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: "Тип"),
                    items: ["окно", "дверь", "ниша", "откос"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedType = v!),
                  ),
                  TextField(
                    controller: controllers["ширина"],
                    decoration: const InputDecoration(labelText: "Ширина (м)"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: controllers["высота"],
                    decoration: const InputDecoration(labelText: "Высота (м)"),
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Название элемента"),
                    onChanged: (v) => customName = v,
                  ),
                  TextField(
                    controller: controllers["value"],
                    decoration: const InputDecoration(labelText: "Количество"),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(labelText: "Ед. изм."),
                    items: ["шт", "м/п", "м²"]
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedUnit = v!),
                  ),
                ],
                TextField(
                  controller: controllers["отступ"],
                  decoration: const InputDecoration(
                      labelText: "Отступ от начала стены (м)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: controllers["floorOffset"],
                  decoration:
                      const InputDecoration(labelText: "Высота от пола (м)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: controllers["ceilingOffset"],
                  decoration:
                      const InputDecoration(labelText: "От потолка (м)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Отмена"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(isEdit ? "Сохранить" : "Добавить в стену"),
            onPressed: () {
              final id = initial?.id ??
                  "${wallId}_${selectedType}_${DateTime.now().millisecondsSinceEpoch}";

              final Map<String, dynamic> params = {
                "отступ": _parse(controllers["отступ"]!.text),
                "floorOffset": _parse(controllers["floorOffset"]!.text),
                "от потолка": _parse(controllers["ceilingOffset"]!.text),
              };

              if (mode == "Стандартный") {
                params["ширина"] = _parse(controllers["ширина"]!.text);
                params["высота"] = _parse(controllers["высота"]!.text);
              } else {
                params["value"] = _parse(controllers["value"]!.text);
                params["unit"] = selectedUnit;
              }

              Navigator.pop(
                context,
                WallElement(
                  id: id,
                  category:
                      mode == "Стандартный" ? "Строительный" : "Универсальный",
                  type: mode == "Стандартный" ? selectedType : customName,
                  params: params,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

double _parse(String input) {
  if (input.isEmpty) return 0.0;
  return double.tryParse(input.replaceAll(",", ".")) ?? 0.0;
}
