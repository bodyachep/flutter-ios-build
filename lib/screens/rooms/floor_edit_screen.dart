import 'package:flutter/material.dart';

import '/models/floor.dart';

class FloorEditScreen extends StatefulWidget {
  final Floor floor;

  const FloorEditScreen({super.key, required this.floor});

  @override
  _FloorEditScreenState createState() => _FloorEditScreenState();
}

class _FloorEditScreenState extends State<FloorEditScreen> {
  late TextEditingController widthController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    widthController =
        TextEditingController(text: widget.floor.width.toString());
    heightController =
        TextEditingController(text: widget.floor.height.toString());
  }

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Редактировать пол")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: widthController,
              decoration: InputDecoration(labelText: "Ширина пола (м)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: "Высота пола (м)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.floor.width = double.tryParse(widthController.text) ??
                      widget.floor.width;
                  widget.floor.height =
                      double.tryParse(heightController.text) ??
                          widget.floor.height;
                });
                Navigator.pop(context);
              },
              child: Text("💾 Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}
