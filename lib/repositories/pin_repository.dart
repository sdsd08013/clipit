import 'package:sqflite/sqflite.dart';

import '../models/pin.dart';
import 'database.dart';

class PinRepository {
  Future<int> savePin(String text) async {
    final db = await database;
    return db.insert(
        'notes',
        {
          "text": text,
          "created_at": DateTime.now().toUtc().toIso8601String(),
          "updated_at": DateTime.now().toUtc().toIso8601String()
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<PinList?> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: "id DESC",
    );
    if (maps.isNotEmpty) {
      return PinList(
          value: List.generate(maps.length, (index) {
        if (index == 0) {
          return Pin.fromMap(maps[index], true);
        } else {
          return Pin.fromMap(maps[index], false);
        }
      }));
    }
    return null;
  }
}
