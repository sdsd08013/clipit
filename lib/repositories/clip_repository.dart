import 'package:sqflite/sqflite.dart';
import '../models/clip.dart';
import 'database.dart';

class ClipRepository {
  Future<void> dropTable() async {
    await deleteDatabase(await getDatabasesPath());
  }

  Future<ClipList?> getClips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clips',
      orderBy: "id DESC",
    );
    if (maps.isNotEmpty) {
      return ClipList(
          value: List.generate(maps.length, (index) {
        if (index == 0) {
          return Clip.fromMap(maps[index], true);
        } else {
          return Clip.fromMap(maps[index], false);
        }
      }));
    }
    return null;
  }

  Future<void> deleteClip(int id) async {
    final db = await database;
    db.delete('clips', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveClip(String clipText) async {
    final db = await database;
    return db.insert(
        'clips',
        {
          "text": clipText,
          "count": 1,
          "created_at": DateTime.now().toUtc().toIso8601String(),
          "updated_at": DateTime.now().toUtc().toIso8601String()
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveClips(List<Clip> clips) async {
    final db = await database;
    final batch = db.batch();
    for (var clip in clips) {
      batch.insert('clips', clip.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    batch.commit();
  }

  Future<void> updateClip(Clip clip) async {
    final db = await database;
    db.update('clips', clip.toMap(), where: 'id=?', whereArgs: [clip.id]);
  }
}
