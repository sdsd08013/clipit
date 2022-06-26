import 'package:clipit/models/history.dart';
import 'package:clipit/models/pin.dart';

class SearchResult {
  HistoryList histories;
  PinList pins;

  SearchResult({required this.histories, required this.pins});

  bool get isNotEmpty => histories.value.isNotEmpty && pins.value.isNotEmpty;
}
