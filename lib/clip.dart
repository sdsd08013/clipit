import 'package:clipit/color.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart' as html2md;

class ClipList {
  int currentIndex = 0;
  List<Clip> value;
  ClipList({required this.value});

  Clip get currentClip {
    return value[currentIndex];
  }

  ClipList insertToFirst(Clip clip) {
    value[currentIndex].isSelected = false;
    value.insert(0, clip);
    currentIndex = 0;
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

  void deleteCurrentClip() {
    // clipboardと同様のclipを削除しようとすると削除できなくなる
    final target = value[currentIndex];
    value.remove(target);
    decrement();
  }

  bool isExist(String result) {
    return value.where((element) => element.text == result).isNotEmpty;
  }
}

class Clip {
  int id;
  String text;
  bool isSelected;

  Clip({required this.id, required this.text, required this.isSelected});

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
    if (trimText.length > 50) {
      return "${trimText.substring(0, 50)}...";
    } else {
      return trimText;
    }
  }

  Map<String, dynamic> toMap() {
    return {'text': text};
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
}
