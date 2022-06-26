import 'package:collection/collection.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:intl/intl.dart';

final formatter = DateFormat("yyyy/MM/dd HH:mm");

class Selectable {
  int id;
  String text;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isSelected;
  String mdText = "";
  String trimText = "";
  String plainText = "";
  Selectable(
      {required this.id,
      required this.text,
      required this.createdAt,
      required this.updatedAt,
      required this.isSelected}) {
    mdText = html2md.convert(text, styleOptions: {'codeBlockStyle': 'fenced'});
    trimText = plainText.replaceAll(' ', '').replaceAll('\n', '');

    if (parse(text).documentElement != null) {
      plainText = parse(text).documentElement!.text;
    }
  }

  String subText() {
    if (trimText.length > 30) {
      return "${trimText.substring(0, 30)}...\n${formatter.format(createdAt)}";
    } else {
      return "$trimText\n${formatter.format(createdAt)}";
    }
  }
}

class SelectableList {
  int currentIndex = 0;
  String listTitle = "";
  List<Selectable> value;
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

  void selectFirstItem() {
    switchItem(0);
  }

  void selectLastItem() {
    switchItem(value.length - 1);
  }
}
