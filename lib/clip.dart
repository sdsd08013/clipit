import 'package:clipit/color.dart';
import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;

class ClipDTO {
  int id;
  String text;
  ClipDTO({required this.id, required this.text});
}

class Clip {
  String plainText;
  String htmlText;
  String mdText = "";
  bool isSelected = false;

  Clip({required this.htmlText, required this.plainText}) {
    mdText = html2md.convert(htmlText);
  }
  //text = s.replaceAll(' ', '').replaceAll('　', '');

  String get trimText {
    return plainText.replaceAll(' ', '').replaceAll('\n', '');
  }

  String subText() {
    if (trimText.length > 50) {
      return "${trimText.substring(0, 50)}...";
    } else {
      return trimText;
    }
  }

  Map<String, dynamic> toMap() {
    return {'plainText': plainText, 'htmlText': htmlText};
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

class ClipNotifier extends ChangeNotifier {
  List<Clip>? clips;
  void updateClips(Clip clip) {
    clips?.add(clip);
    notifyListeners();
  }
}
