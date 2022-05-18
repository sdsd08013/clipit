import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'clip.dart';

class ClipRepository {
  Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'clipit.db'),
      onCreate: (db, version) {
        //db.delete('clips');
        return db.execute('''
          CREATE TABLE clips(id INTEGER PRIMARY KEY, text TEXT NOT NULL, count INTEGER, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)
          ''');
      },
      version: 1,
    );
  }

  Future<void> dropTable() async {
    await deleteDatabase(await getDatabasesPath());
  }

  Future<ClipList?> getClips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('clips', orderBy: "id desc");
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
    return db.insert('clips', {'text': clipText},
        conflictAlgorithm: ConflictAlgorithm.ignore);
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
