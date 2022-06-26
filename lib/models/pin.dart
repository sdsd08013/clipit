import 'package:clipit/models/selectable.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:html2md/html2md.dart' as html2md;

final formatter = DateFormat("yyyy/MM/dd HH:mm");

class Pin extends Selectable {
  Pin(
      {required id,
      required text,
      required isSelected,
      required createdAt,
      required updatedAt})
      : super(
            id: id,
            text: text,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSelected: isSelected);

  factory Pin.fromMap(Map<String, dynamic> json, bool isSelected) => Pin(
      id: json['id'],
      text: json['text'],
      isSelected: false,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal());
}

class PinList extends SelectableList {
  @override
  String listTitle = "pinned";
  PinList(
      {required super.value,
      required super.currentIndex,
      required super.listTitle});

  PinList insertToFirst(Pin pin) {
    if (value.isEmpty) {
      return copyWith(value: [pin]) as PinList;
    } else {
      value.insert(0, pin);
      return copyWith(currentIndex: 0, value: value) as PinList;
    }
  }
}
