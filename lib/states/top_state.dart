import 'package:flutter/cupertino.dart';
import 'package:clipit/models/history.dart';
import 'package:clipit/models/pin.dart';
import 'package:clipit/models/selectable.dart';
import 'package:clipit/models/side_type.dart';
import 'package:clipit/models/trash.dart';

@immutable
class TopState {
  final SelectableList histories;
  final SelectableList pins;
  final SelectableList trashes;
  final List<SelectableList> searchResults;
  final ScreenType type;

  const TopState(
      {required this.histories,
      required this.pins,
      required this.trashes,
      required this.searchResults,
      required this.type});

  TopState copyWith(
      {SelectableList? histories,
      SelectableList? pins,
      SelectableList? trashes,
      List<SelectableList>? searchResults,
      ScreenType? type}) {
    return TopState(
        histories: histories ?? this.histories,
        pins: pins ?? this.pins,
        trashes: trashes ?? this.trashes,
        searchResults: searchResults ?? this.searchResults,
        type: type ?? this.type);
  }

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

  TopState decrementCurrentItems() {
    if (type == ScreenType.CLIP) {
      return copyWith(histories: histories.decrementIndex());
    } else if (type == ScreenType.PINNED) {
      return copyWith(pins: pins.decrementIndex());
    } else if (type == ScreenType.TRASH) {
      return copyWith(trashes: trashes.decrementIndex());
    } else {
      return copyWith(histories: histories.decrementIndex());
    }
  }

  TopState incrementCurrentItems() {
    if (type == ScreenType.CLIP) {
      return copyWith(histories: histories.incrementIndex());
    } else if (type == ScreenType.PINNED) {
      return copyWith(pins: pins.incrementIndex());
    } else if (type == ScreenType.TRASH) {
      return copyWith(trashes: trashes.incrementIndex());
    } else {
      return copyWith(histories: histories.incrementIndex());
    }
  }

  TopState switchCurrentItems(int targetIndex) {
    if (type == ScreenType.CLIP) {
      return copyWith(histories: histories.switchItem(targetIndex));
    } else if (type == ScreenType.PINNED) {
      return copyWith(pins: pins.switchItem(targetIndex));
    } else if (type == ScreenType.TRASH) {
      return copyWith(trashes: trashes.switchItem(targetIndex));
    } else {
      return copyWith(histories: histories.switchItem(targetIndex));
    }
  }

  bool isPinExist(String text) => pins.isExist(text);
  bool isHistoryExist(String text) => histories.isExist(text);
  bool shouldUpdateHistory(String text) => histories.shouldUpdate(text);

  Future<List<Selectable>> searchHistories(String text) async {
    return histories.value
        .where((element) => element.plainText.contains(text))
        .toList();
  }

  Future<List<Selectable>> searchPins(String text) async {
    return pins.value
        .where((element) => element.plainText.contains(text))
        .toList();
  }

  List<SelectableList> getSearchResult(String text) {
    // final searchedHistories = histories.value
    //     .where((element) => element.plainText.contains(text))
    //     .toList();
    // final searchedPins = pins.value
    //     .where((element) => element.plainText.contains(text))
    //     .toList();
    // final searchedHistories = searchHistories(text);
    // searchedHistories
    //     .then((result) => searchResults.add(HistoryList(value: result)));
    // final searchedPins = searchPins(text);
    // searchedPins.then((result) => searchResults.add(PinList(value: result)));

    return searchResults;

    // if (searchedHistories.isNotEmpty) {
    //   searchResults.add(HistoryList(value: searchedHistories));
    // }
    // if (searchedPins.isNotEmpty) {
    //   searchResults.add(PinList(value: searchedPins));
    // }
    //searchResults.first.selectFirstItem();
  }

  // void clearSearchResult() {
  //   searchResults = [];
  // }
}
