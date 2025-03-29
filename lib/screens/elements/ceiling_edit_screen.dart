import 'package:flutter/material.dart';

import '../../models/bigceiling.dart';

class CeilingEditScreen extends StatefulWidget {
  final BigCeiling ceiling;

  const CeilingEditScreen({super.key, required this.ceiling});

  @override
  _CeilingEditScreenState createState() => _CeilingEditScreenState();
}

class _CeilingEditScreenState extends State<CeilingEditScreen> {
  late TextEditingController widthController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    widthController =
        TextEditingController(text: widget.ceiling.width.toString());
    heightController =
        TextEditingController(text: widget.ceiling.height.toString());
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
      appBar: AppBar(title: Text("Редактировать потолок")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: widthController,
              decoration: InputDecoration(labelText: "Ширина потолка (м)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: "Высота потолка (м)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.ceiling.width =
                      double.tryParse(widthController.text) ??
                          widget.ceiling.width;
                  widget.ceiling.height =
                      double.tryParse(heightController.text) ??
                          widget.ceiling.height;
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
