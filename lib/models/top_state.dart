import 'package:clipit/models/history.dart';
import 'package:clipit/models/pin.dart';
import 'package:clipit/models/selectable.dart';
import 'package:clipit/models/side_type.dart';
import 'package:clipit/models/trash.dart';

class TopState {
  HistoryList histories;
  PinList pins;
  TrashList trashes;
  List<SelectableList> searchResults = [];
  ScreenType type = ScreenType.CLIP;

  TopState(
      {required this.histories, required this.pins, required this.trashes});

  SelectableList get currentItems {
    if (type == ScreenType.CLIP) {
      return histories;
    } else if (type == ScreenType.PINNED) {
      return pins;
    } else if (type == ScreenType.TRASH) {
      return trashes;
    } else {
      return histories;
    }
  }

  Selectable get currentItem => currentItems.currentItem;

  int get currentIndex {
    return currentItems.currentIndex;
  }

  bool get showSearchResult => searchResults.isNotEmpty;

  void decrementCurrentItems() {
    if (type == ScreenType.CLIP) {
      histories.decrementIndex();
    } else if (type == ScreenType.PINNED) {
      pins.decrementIndex();
    } else if (type == ScreenType.TRASH) {
      trashes.decrementIndex();
    } else {
      histories.decrementIndex();
    }
  }

  void incrementCurrentItems() {
    if (type == ScreenType.CLIP) {
      histories.incrementIndex();
    } else if (type == ScreenType.PINNED) {
      pins.incrementIndex();
    } else if (type == ScreenType.TRASH) {
      trashes.incrementIndex();
    } else {
      histories.incrementIndex();
    }
  }

  void switchCurrentItems(int targetIndex) {
    if (type == ScreenType.CLIP) {
      histories.switchItem(targetIndex);
    } else if (type == ScreenType.PINNED) {
      pins.switchItem(targetIndex);
    } else if (type == ScreenType.TRASH) {
      trashes.switchItem(targetIndex);
    } else {
      histories.switchItem(targetIndex);
    }
  }

  bool isPinExist(String text) => pins.isExist(text);
  bool isHistoryExist(String text) => histories.isExist(text);
  bool shouldUpdateHistory(String text) => histories.shouldUpdate(text);

  void setSearchResult(String text) {
    final searchedHistories = histories.value
        .where((element) => element.text.contains(text))
        .toList();
    final searchedPins =
        pins.value.where((element) => element.text.contains(text)).toList();
    searchResults = [
      HistoryList(value: searchedHistories),
      PinList(value: searchedPins)
    ];
  }

  void clearSearchResult() {
    searchResults = [];
  }
}
