import 'package:collection/collection.dart';
import 'package:html2md/html2md.dart' as html2md;

class Selectable {
  int id;
  String text;
  final DateTime createdAt;
  DateTime updatedAt;
  Selectable(
      {required this.id,
      required this.text,
      required this.createdAt,
      required this.updatedAt});

  String get mdText {
    print("==============>text:${text}");
    return html2md.convert(text);
  }
}

class SelectableList {
  int currentIndex = 0;
  List<dynamic> value;
  SelectableList({required this.value});

  dynamic get currentItem {
    return value[currentIndex];
  }

  void decrementIndex() {
    if (currentIndex == 0) return;
    value[currentIndex].isSelected = false;
    value[currentIndex - 1].isSelected = true;
    currentIndex--;
  }

  void incrementIndex() {
    if (currentIndex == value.length - 1) return;
    value[currentIndex].isSelected = false;
    value[currentIndex + 1].isSelected = true;
    currentIndex++;
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

  void switchItem(int targetIndex) {
    final target = value[targetIndex];
    currentItem.isSelected = false;
    target.isSelected = true;
    currentIndex = targetIndex;
  }
}
