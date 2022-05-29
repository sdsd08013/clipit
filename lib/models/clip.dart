import 'package:clipit/models/selectable.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

class ClipList extends SelectableList {
  @override
  String listTitle = "history";
  ClipList({required super.value});

  ClipList insertToFirst(Clip clip) {
    if (value.isEmpty) {
      value = [clip];
    } else {
      value[currentIndex].isSelected = false;
      value.insert(0, clip);
      value[0].isSelected = true;
      currentIndex = 0;
    }
    return this;
  }

  void updateTargetClip(String result) {
    final Clip target =
        value.where((element) => element.text == result).firstOrNull as Clip;
    if (target != null) {
      target.count++;
      target.updatedAt = DateTime.now();
      target.isSelected = true;
      value[currentIndex].isSelected = false;
      value[currentIndex] = target;
    }
  }

  void updateCurrentClip() {
    final target = value[currentIndex] as Clip;
    target.count++;
    target.updatedAt = DateTime.now();
    value[currentIndex] = target;
  }

  void deleteTargetClip(Clip target) {
    value.remove(target);
    decrementIndex();
  }

  void deleteCurrentClip() {
    // clipboardと同様のclipを削除しようとすると削除できなくなる
    final target = value[currentIndex];
    value.remove(target);
    if (currentIndex == 0) {
      value[currentIndex].isSelected = true;
    } else {
      value[currentIndex - 1].isSelected = true;
      currentIndex--;
    }
  }
}

class Clip extends Selectable {
  int count;
  final formatter = DateFormat("yyyy/MM/dd HH:mm");

  Clip(
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

  factory Clip.fromMap(Map<String, dynamic> json, bool isSelected) => Clip(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      isSelected: isSelected);
}
