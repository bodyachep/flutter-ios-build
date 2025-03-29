import 'package:flutter/material.dart';

class ProjectProvider with ChangeNotifier {
  List<String> _projects = ["Дом 1", "Офис 2"];
  ProjectProvider() {
    print("✅ ProjectProvider создан!"); // Проверка
  }

  List<String> get projects => _projects;

  void addProject(String name) {
    _projects.add(name);
    print("✅ Добавлен проект: $name"); // Проверяем в консоли
    notifyListeners(); // Оповещает UI об изменениях
  }
}
