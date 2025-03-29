import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/providers/room_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  test('Загрузка комнат из Firestore', () async {
    final roomProvider = RoomProvider();

    // Подставь реальный placeId для теста
    const testPlaceId = 'DERBOC';

    await roomProvider.loadRooms(testPlaceId);

    expect(roomProvider.rooms.isNotEmpty, true, reason: "Комнаты не загружены");
    expect(roomProvider.rooms.first.placeId, testPlaceId);
  });
}
