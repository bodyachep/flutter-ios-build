import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'models/bigelement.dart'; // ✅ Исправлено (было с заглавной "C")
import '../screens/objects/home_screen.dart';
import '../screens/objects/place_screen.dart'; // 🔥 Firebase конфигурация
import 'models/bigceiling.dart'; // ✅ Исправлено (было с заглавной "C")
import 'models/floor.dart'; // ✅ Проверили регистр
import 'models/place.dart';
import 'models/room.dart';
import 'models/wall.dart';
import 'project_provider.dart';
import 'providers/place_provider.dart';
import 'providers/room_provider.dart';
import 'providers/wall_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // ✅ Важно для Web!
    );
  } catch (e) {
    print("🔥 Ошибка Firebase: $e"); // ✅ Показываем ошибку в консоли
  }
  // ✅ Подключение Firestore Emulator:
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // print("🧪 Firestore работает через локальный эмулятор");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WallProvider()),
          ChangeNotifierProvider(create: (_) => RoomProvider()),
          ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ],
        child: MaterialApp(
          title: 'Планировка',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: HomeScreen(),
        ),
      );
    } catch (e) {
      print("🔥 Ошибка в MultiProvider: $e");
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Ошибка загрузки приложения")),
        ),
      ); // ✅ Теперь всегда есть возвращаемый виджет
    }
  }
}
