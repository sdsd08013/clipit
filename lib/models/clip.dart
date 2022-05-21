import 'package:clipit/color.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart' as html2md;

import 'note.dart';

class ClipList {
  int currentIndex = 0;
  List<Clip> value;
  ClipList({required this.value});

  Clip get currentClip {
    return value[currentIndex];
  }

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

  void decrement() {
    if (currentIndex == 0 || value.length < 2) return;
    value[currentIndex].isSelected = false;
    value[currentIndex - 1].isSelected = true;
    currentIndex--;
  }

  void increment() {
    if (currentIndex == value.length - 1 || value.length < 2) return;
    value[currentIndex].isSelected = false;
    value[currentIndex + 1].isSelected = true;
    currentIndex++;
  }

  void switchClip(int targetIndex) {
    final target = value[targetIndex];
    currentClip.isSelected = false;
    target.isSelected = true;
    currentIndex = targetIndex;
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

  bool isExist(String result) {
    return value.where((element) => element.text == result).isNotEmpty;
  }

  bool shouldUpdate(String result) {
    final clip = value.where((element) => element.text == result).firstOrNull;
    if (clip == null) {
      return true;
    } else {
      return clip.updatedAt
          .add(const Duration(minutes: 1))
          .isBefore(DateTime.now());
    }
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

  Color backgroundColor(BuildContext context) {
    if (isSelected) {
      //return Theme.of(context).highlightColor;
      return side2ndBackgroundSelect;
    } else {
      return side2ndBackground;
      //return Theme.of(context).cardColor;
    }
  }

  factory Clip.fromMap(Map<String, dynamic> json, bool isSelected) => Clip(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      isSelected: isSelected);
}
