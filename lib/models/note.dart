import 'package:clipit/models/selectable.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:html2md/html2md.dart' as html2md;

final formatter = DateFormat("yyyy/MM/dd HH:mm");

class Note extends Selectable {
  bool isSelected = false;

  Note(
      {required id,
      required text,
      required isSelected,
      required createdAt,
      required updatedAt})
      : super(id: id, text: text, createdAt: createdAt, updatedAt: updatedAt);

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
      isSelected: false,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal());
}

class NoteList extends SelectableList {
  NoteList({required super.value});

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
