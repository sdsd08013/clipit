import 'package:clipit/models/selectable.dart';

class TopState {
  SelectableList clips;
  SelectableList notes;
  SelectableList trashes;

  TopState({required this.clips, required this.notes, required this.trashes});
}
