import 'package:clipit/color.dart';
import 'package:flutter/material.dart';

class ClipDTO {
  int id;
  String text;
  ClipDTO({required this.id, required this.text});
}

class Clip {
  String text;
  bool isSelected = false;

  Clip({required this.text});
  //text = s.replaceAll(' ', '').replaceAll('　', '');

  String subText() {
    final trimText = text.replaceAll(' ', '').replaceAll('\n', '');
    if (trimText.length > 50) {
      return "${trimText.substring(0, 50)}...";
    } else {
      return "$trimText";
    }
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'isSelected': isSelected};
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
