import 'package:clipit/models/selectable.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

class HistoryList extends SelectableList {
  @override
  String listTitle = "history";
  HistoryList(
      {required super.value,
      required super.currentIndex,
      required super.listTitle});

  void updateTargetHistory(String result) {
    final History target =
        value.where((element) => element.text == result).firstOrNull as History;
    if (target != null) {
      target.count++;
      target.updatedAt = DateTime.now();
      target.isSelected = true;
      value[currentIndex].isSelected = false;
      value[currentIndex] = target;
    }
  }

  void updateCurrentHistory() {
    final target = value[currentIndex] as History;
    target.count++;
    target.updatedAt = DateTime.now();
    value[currentIndex] = target;
  }
}

class History extends Selectable {
  int count;
  final formatter = DateFormat("yyyy/MM/dd HH:mm");

  History(
      {required id,
      required text,
      required this.count,
      required isSelected,
      required createdAt,
      required updatedAt})
      : super(
            id: id,
            text: text,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSelected: isSelected);

  @override
  String get trimText {
    return plainText.replaceAll(' ', '').replaceAll('\n', '');
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      "created_at": createdAt.toUtc().toIso8601String(),
      "updated_at": updatedAt.toUtc().toIso8601String()
    };
  }

  factory History.fromMap(Map<String, dynamic> json, bool isSelected) =>
      History(
          id: json['id'],
          text: json['text'],
          count: json['count'],
          createdAt: DateTime.parse(json['created_at']).toLocal(),
          updatedAt: DateTime.parse(json['updated_at']).toLocal(),
          isSelected: isSelected);

  @override
  String get name => text;
}
