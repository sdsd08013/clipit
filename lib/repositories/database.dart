import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> get database async {
  return openDatabase(
    join(await getDatabasesPath(), 'clipit.db'),
    onCreate: (db, version) {
      //db.delete('clips');
      db.execute('''
          CREATE TABLE clips(id INTEGER PRIMARY KEY, text TEXT NOT NULL, count INTEGER, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
          ''');
      return db.execute('''
          CREATE TABLE notes(id INTEGER PRIMARY KEY, text TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
          ''');
    },
    version: 1,
  );
}
