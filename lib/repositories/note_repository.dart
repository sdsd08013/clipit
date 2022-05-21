import 'package:sqflite/sqflite.dart';

import '../models/note.dart';
import 'database.dart';

class NoteRepository {
  Future<int> saveNote(String text) async {
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

  Future<NoteList?> getClips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clips');
    if (maps.isNotEmpty) {
      return NoteList(
          value: List.generate(maps.length, (index) {
        if (index == 0) {
          return Note.fromMap(maps[index], true);
        } else {
          return Note.fromMap(maps[index], false);
        }
      }));
    }
    return null;
  }
}
