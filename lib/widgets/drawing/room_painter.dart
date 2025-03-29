import 'dart:math';
import 'package:flutter/material.dart';
import '/models/wall.dart';
import '/models/wall_element.dart';

class RoomPainter extends CustomPainter {
  final List<Wall> walls;
  final double scale;

  RoomPainter(this.walls, {this.scale = 20});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    Offset start = Offset(size.width / 2, size.height / 2);
    double currentAngle = 0;

    for (var wall in walls) {
      if (wall.length == 0 && wall.order == 0) {
        continue;
      } // ⛔ пропускаем мета-стену

      double angleOffset =
          wall.direction == "inward" ? wall.angle : -wall.angle;
      currentAngle += angleOffset;
      double angleRad = currentAngle * pi / 180;

      Offset end = Offset(
        start.dx + wall.length * scale * cos(angleRad),
        start.dy + wall.length * scale * sin(angleRad),
      );

      // 🔹 Отрисовка стены
      canvas.drawLine(start, end, paint);

      // 🔹 Отображение длины
      Offset textPosition =
          Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      textPainter.text = TextSpan(text: "${wall.length} м", style: textStyle);
      textPainter.layout();
      Offset textOffset = Offset(
        15 * cos(angleRad + pi / 2),
        15 * sin(angleRad + pi / 2),
      );
      canvas.save();
      canvas.translate(
          textPosition.dx + textOffset.dx, textPosition.dy + textOffset.dy);
      canvas.rotate(angleRad);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset(0, -30));
      canvas.restore();

      // 🔺 Стрелка направления
      final arrowPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 1.0;

      double arrowAngle =
          wall.direction == "inward" ? currentAngle + 30 : currentAngle - 30;
      double arrowRad = arrowAngle * pi / 180;

      Offset arrowStart = Offset(
        end.dx - 10 * cos(angleRad),
        end.dy - 10 * sin(angleRad),
      );

      Offset arrowLeft = Offset(
        arrowStart.dx - 10 * cos(arrowRad),
        arrowStart.dy - 10 * sin(arrowRad),
      );

      Offset arrowRight = Offset(
        arrowStart.dx + 10 * cos(arrowRad),
        arrowStart.dy + 10 * sin(arrowRad),
      );

      canvas.drawLine(end, arrowLeft, arrowPaint);
      canvas.drawLine(end, arrowRight, arrowPaint);

      // 🔷 Отрисовка строительных элементов (окно, дверь и т.п.)
      for (var element in wall.elements) {
        if (element.category != "строительный") continue;

        final p = element.params;
        final width = _parse(p["ширина"]);
        final offset = _parse(p["отступ"]);

        final elementStart = Offset(
          start.dx + offset * scale * cos(angleRad),
          start.dy + offset * scale * sin(angleRad),
        );

        final elementEnd = Offset(
          elementStart.dx + width * scale * cos(angleRad),
          elementStart.dy + width * scale * sin(angleRad),
        );

        final elementPaint = Paint()
          ..color = Colors.brown.shade200
          ..strokeWidth = 4.0;

        canvas.drawLine(elementStart, elementEnd, elementPaint);
      }

      start = end; // Переход к следующей стене
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

double _parse(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String)
    return double.tryParse(value.replaceAll(",", ".")) ?? 0.0;
  return 0.0;
}
