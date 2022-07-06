import 'package:clipit/models/selectable.dart';
import 'package:intl/intl.dart';

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

  @override
  String get trimText {
    return plainText.replaceAll(' ', '').replaceAll('\n', '');
  }

  @override
  String get name => text;

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
}
