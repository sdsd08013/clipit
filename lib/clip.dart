import 'package:flutter/material.dart';

class Clip {
  String text = "";
  bool isSelected = false;
  int index = 0;

  Clip(String s) {
    text = s.replaceAll(' ', '').replaceAll('　', '');
  }

  String subText() {
    if (text.length > 50) {
      return "${text.substring(0, 50)}...";
    } else {
      return "$text...";
    }
  }

  Color backgroundColor() {
    if (isSelected) {
      return Colors.brown;
    } else {
      return Colors.white;
    }
  }

  void incrementIndex() {
    index++;
  }

  void decrementIndex() {
    index--;
  }
}

class ClipNotifier extends ChangeNotifier {
  List<Clip>? clips;
  void updateClips(Clip clip) {
    clips?.add(clip);
    notifyListeners();
  }
}
