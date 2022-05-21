import 'package:html/parser.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat("yyyy/MM/dd HH:mm");

class Note {
  int id;
  String text;
  final DateTime createdAt;
  DateTime updatedAt;

  Note(
      {required this.id,
      required this.text,
      required this.createdAt,
      required this.updatedAt});

  String get trimText {
    return plainText.replaceAll(' ', '').replaceAll('\n', '');
  }

  String get plainText {
    var doc = parse(text);
    if (doc.documentElement != null) {
      String parsedstring = doc.documentElement!.text;
      return parsedstring;
    }
    return "";
  }

  String subText() {
    if (trimText.length > 30) {
      return "${trimText.substring(0, 30)}...\n${formatter.format(createdAt)}";
    } else {
      return "$trimText\n${formatter.format(createdAt)}";
    }
  }

  factory Note.fromMap(Map<String, dynamic> json, bool isSelected) => Note(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal());
}

class NoteList {
  int currentIndex = 0;
  List<Note> value;
  NoteList({required this.value});

  Note get currentClip {
    return value[currentIndex];
  }

  NoteList insertToFirst(Note note) {
    if (value.isEmpty) {
      value = [note];
    } else {
      value.insert(0, note);
      currentIndex = 0;
    }
    return this;
  }
}
