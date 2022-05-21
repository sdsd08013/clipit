import 'package:collection/collection.dart';

class Selectable {
  int currentIndex = 0;
  List<dynamic> value;
  Selectable({required this.value});

  dynamic get currentItem {
    return value[currentIndex];
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
