import 'package:clipit/models/selectable.dart';
import 'package:collection/collection.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:html2md/html2md.dart' as html2md;

import 'pin.dart';

class Trash extends Selectable {
  Trash(
      {required id,
      required text,
      required isSelected,
      required createdAt,
      required updatedAt})
      : super(
            id: id,
            text: text,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSelected: isSelected);

  factory Trash.fromMap(Map<String, dynamic> json, bool isSelected) => Trash(
      id: json['id'],
      text: json['text'],
      isSelected: false,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal());
}

class TrashList extends SelectableList {
  @override
  String listTitle = "trashes";

  TrashList({required super.value});

  TrashList insertToFirst(Trash trash) {
    if (value.isEmpty) {
      value = [trash];
    } else {
      value.insert(0, trash);
      currentIndex = 0;
    }
    return this;
  }
}
