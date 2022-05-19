class Note {
  int id;
  String text;
  final DateTime createdAt;
  DateTime updatedAt;

  bool isSelected;

  Note(
      {required this.id,
      required this.text,
      required this.isSelected,
      required this.createdAt,
      required this.updatedAt});
}
