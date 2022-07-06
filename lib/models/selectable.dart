import 'package:clipit/models/directable.dart';
import 'package:clipit/models/tree_node.dart';
import 'package:collection/collection.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:intl/intl.dart';

final formatter = DateFormat("yyyy/MM/dd HH:mm");

class Selectable implements Directable {
  int id;
  String text;
  final DateTime createdAt;
  DateTime updatedAt;
  @override
  bool isSelected;
  @override
  bool isDir = false;
  String mdText = "";
  String trimText = "";
  String plainText = "";
  String subText = "";
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

    if (trimText.length > 30) {
      subText =
          "${trimText.substring(0, 30)}...\n${formatter.format(createdAt)}";
    } else {
      subText = "$trimText\n${formatter.format(createdAt)}";
    }
  }

  @override
  String get name => text;
}

class SelectableList {
  final int currentIndex;
  final String listTitle;
  final List<Selectable> value;
  SelectableList(
      {required this.currentIndex,
      required this.listTitle,
      required this.value});

  SelectableList copyWith(
      {int? currentIndex, String? listTitle, List<Selectable>? value}) {
    return SelectableList(
        currentIndex: currentIndex ?? this.currentIndex,
        listTitle: listTitle ?? this.listTitle,
        value: value ?? this.value);
  }

  dynamic get currentItem {
    return value[currentIndex];
  }

  SelectableList decrementIndex() {
    if (currentIndex == 0) {
      return copyWith();
    } else {
      value[currentIndex].isSelected = false;
      value[currentIndex - 1].isSelected = true;
      return copyWith(currentIndex: currentIndex - 1, value: value);
    }
  }

  SelectableList incrementIndex() {
    if (currentIndex == value.length - 1) {
      return copyWith();
    } else {
      value[currentIndex].isSelected = false;
      value[currentIndex + 1].isSelected = true;
      return copyWith(currentIndex: currentIndex + 1, value: value);
    }
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

  SelectableList switchItem(int targetIndex) {
    value[currentIndex].isSelected = false;
    value[targetIndex].isSelected = true;
    return copyWith(currentIndex: targetIndex, value: value);
  }

  SelectableList deleteCurrentHistory() {
    // todo: override
    value.remove(currentItem);
    if (currentIndex == 0) {
      value[currentIndex].isSelected = true;
      return copyWith(value: value);
    } else {
      value[currentIndex - 1].isSelected = true;
      return copyWith(currentIndex: currentIndex - 1, value: value);
    }
  }

  SelectableList insertToFirst(Selectable item) {
    if (value.isEmpty) {
      return copyWith(value: [item]);
    } else {
      value[currentIndex].isSelected = false;
      value.insert(0, item);
      value[0].isSelected = true;
      return copyWith(currentIndex: 0, value: value);
    }
  }

  SelectableList deleteTargetHistory(Selectable target) {
    value.remove(target);
    final t = copyWith(value: value).value;

    return copyWith(currentIndex: currentIndex - 1, value: t);
  }

  void selectFirstItem() {
    switchItem(0);
  }

  void selectLastItem() {
    switchItem(value.length - 1);
  }

  int getTargetIndex(Selectable target) {
    return value.indexOf(target);
  }
}
