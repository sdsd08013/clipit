import 'package:flutter/material.dart';

class Clip {
  String text = "";
  Clip(String s) {
    text = s;
  }
}

class ClipNotifier extends ChangeNotifier {
  List<Clip>? clips;
  void updateClips(Clip clip) {
    clips?.add(clip);
    notifyListeners();
  }
}
