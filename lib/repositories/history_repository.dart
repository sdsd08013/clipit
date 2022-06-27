import 'package:sqflite/sqflite.dart';
import '../models/history.dart';
import 'database.dart';

class HistoryRepository {
  Future<void> dropTable() async {
    await deleteDatabase(await getDatabasesPath());
  }

  Future<HistoryList?> search(text) async {
    final db = await database;
    final maps =
        await db.query("clips", where: "name LIKE ?", whereArgs: ["%${text}%"]);
  }

  Future<HistoryList?> getClips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clips',
      orderBy: "id DESC",
    );
    if (maps.isNotEmpty) {
      return HistoryList(
          currentIndex: 0,
          listTitle: "history",
          value: List.generate(maps.length, (index) {
            if (index == 0) {
              return History.fromMap(maps[index], true);
            } else {
              return History.fromMap(maps[index], false);
            }
          }));
    }
    return null;
  }

  Future<void> deleteHistory(int id) async {
    final db = await database;
    db.delete('clips', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveHistory(String clipText) async {
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

  Future<void> saveHistorys(List<History> clips) async {
    final db = await database;
    final batch = db.batch();
    for (var clip in clips) {
      batch.insert('clips', clip.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    batch.commit();
  }

  Future<void> updateHistory(History history) async {
    final db = await database;
    db.update('clips', history.toMap(), where: 'id=?', whereArgs: [history.id]);
  }
}
