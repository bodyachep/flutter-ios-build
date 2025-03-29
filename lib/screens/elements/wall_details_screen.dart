import 'package:flutter/material.dart';
import '/models/wall_element.dart';
import '/models/wall.dart';

class WallDetailsScreen extends StatelessWidget {
  final Wall wall;

  const WallDetailsScreen({super.key, required this.wall});
  String _formatElement(WallElement e) {
    final p = e.params;

    if (e.category == "строительный") {
      final width = p["ширина"] ?? "?";
      final height = p["высота"] ?? "?";
      final depth = p.containsKey("глубина") ? " x ${p["глубина"]} м" : "";
      final offset = p["отступ"] ?? "?";

      return "${e.type}: $width x $height$depth м, отступ: $offset м";
    }

    if (e.category == "универсальный") {
      final value = p["value"] ?? "?";
      final unit = p["unit"] ?? "";
      final offset = p["отступ"] ?? "?";

      return "${e.type}: $value $unit, отступ: $offset м";
    }

    // fallback
    return "${e.type}: параметры не распознаны (${p.toString()})";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Детали стены")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📏 Длина: ${wall.length} м", style: TextStyle(fontSize: 18)),
            Text("📐 Высота: ${wall.height} м", style: TextStyle(fontSize: 18)),
            Text("🔄 Угол: ${wall.angle}°", style: TextStyle(fontSize: 18)),
            Text("🧱 Толщина: ${wall.thickness} м",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text("Элементы стены:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: wall.elements.isEmpty
                  ? Center(child: Text("Нет элементов"))
                  : ListView.builder(
                      itemCount: wall.elements.length,
                      itemBuilder: (context, index) {
                        final element = wall.elements[index];
                        return ListTile(
                          title: Text("🔹 ${element.type}"),
                          subtitle: Text(
                            _formatElement(element),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
