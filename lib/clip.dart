import 'package:flutter/material.dart';

class Clip {
  String text = "";
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
}

class ClipNotifier extends ChangeNotifier {
  List<Clip>? clips;
  void updateClips(Clip clip) {
    clips?.add(clip);
    notifyListeners();
  }
}
