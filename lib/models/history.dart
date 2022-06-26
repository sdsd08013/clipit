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

  HistoryList insertToFirst(History history) {
    if (value.isEmpty) {
      return copyWith(value: [history]) as HistoryList;
    } else {
      value[currentIndex].isSelected = false;
      value.insert(0, history);
      value[0].isSelected = true;
      return copyWith(currentIndex: 0, value: value) as HistoryList;
    }
  }

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

  HistoryList deleteTargetHistory(History target) {
    value.remove(target);
    final t = copyWith(value: value).value;

    return copyWith(currentIndex: currentIndex - 1, value: t) as HistoryList;
  }

  HistoryList deleteCurrentHistory() {
    // historyboardと同様のclipを削除しようとすると削除できなくなる
    value.removeAt(currentIndex);
    if (currentIndex == 0) {
      value[currentIndex].isSelected = true;
      return copyWith(value: value) as HistoryList;
    } else {
      value[currentIndex - 1].isSelected = true;
      return copyWith(currentIndex: currentIndex - 1, value: value)
          as HistoryList;
    }
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
      return "${trimText.substring(0, 30)}...\n${formatter.format(createdAt)}\n$count";
    } else {
      return "$trimText\n${formatter.format(createdAt)}\n$count";
    }
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
}
