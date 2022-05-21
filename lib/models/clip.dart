import 'package:clipit/models/selectable.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart' as html2md;

class ClipList extends Selectable {
  ClipList({required super.value});

  ClipList insertToFirst(Clip clip) {
    if (value.isEmpty) {
      value = [clip];
    } else {
      value[currentIndex].isSelected = false;
      value.insert(0, clip);
      currentIndex = 0;
    }
    return this;
  }

  void updateTargetClip(String result) {
    final target = value.where((element) => element.text == result).firstOrNull;
    if (target != null) {
      target.count++;
      target.updatedAt = DateTime.now();
      value[currentIndex] = target;
    }
  }

  void updateCurrentClip() {
    final target = value[currentIndex];
    target.count++;
    target.updatedAt = DateTime.now();
    value[currentIndex] = target;
  }

  void deleteTargetClip(Clip target) {
    value.remove(target);
    decrement();
  }

  void deleteCurrentClip() {
    // clipboardと同様のclipを削除しようとすると削除できなくなる
    final target = value[currentIndex];
    value.remove(target);
    decrement();
  }
}

class Clip {
  int id;
  String text;
  bool isSelected;
  int count;
  final DateTime createdAt;
  DateTime updatedAt;
  final formatter = DateFormat("yyyy/MM/dd HH:mm");

  Clip(
      {required this.id,
      required this.text,
      required this.count,
      required this.isSelected,
      required this.createdAt,
      required this.updatedAt});

  String get trimText {
    return plainText.replaceAll(' ', '').replaceAll('\n', '');
  }

  String get mdText {
    return html2md.convert(text);
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
