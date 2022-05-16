import 'package:clipit/color.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart' as html2md;

class Clip {
  int id;
  String text;
  bool isSelected;

  Clip({required this.id, required this.text, required this.isSelected});
  //text = s.replaceAll(' ', '').replaceAll('　', '');

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
      return sideBackgroundSelect;
    } else {
      return sideBackground;
      //return Theme.of(context).cardColor;
    }
  }
}
