import 'package:clipit/models/tree_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:clipit/models/selectable.dart';
import 'package:clipit/models/side_type.dart';

@immutable
class TopState {
  final SelectableList histories;
  final SelectableList pins;
  final SelectableList trashes;
  final List<SelectableList> searchResults;
  final TreeNode currentNode;
  final ScreenType type;
  final bool showSearchBar;
  final bool showSearchResult;

  const TopState(
      {required this.histories,
      required this.pins,
      required this.trashes,
      required this.searchResults,
      required this.type,
      required this.showSearchBar,
      required this.showSearchResult,
      required this.currentNode});

  TopState copyWith(
      {SelectableList? histories,
      SelectableList? pins,
      SelectableList? trashes,
      List<SelectableList>? searchResults,
      ScreenType? type,
      bool? showSearchBar,
      bool? showSearchResult,
      TreeNode? currentNode}) {
    return TopState(
        histories: histories ?? this.histories,
        pins: pins ?? this.pins,
        trashes: trashes ?? this.trashes,
        searchResults: searchResults ?? this.searchResults,
        type: type ?? this.type,
        showSearchBar: showSearchBar ?? this.showSearchBar,
        showSearchResult: showSearchResult ?? this.showSearchResult,
        currentNode: currentNode ?? this.currentNode);
  }

  TreeNode get root {
    TreeNode current = currentNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
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

  Future<TopState> getSearchResult(String text) async {
    final searchedHistories = histories.value
        .where((element) => element.plainText.contains(text))
        .toList();
    final searchedPins = pins.value
        .where((element) => element.plainText.contains(text))
        .toList();

    final historyNode =
        TreeNode(name: "history", isDir: true, isSelected: false, children: []);
    final pinNode =
        TreeNode(name: "pin", isDir: true, isSelected: false, children: []);
    if (searchedHistories.isNotEmpty) {
      historyNode.addSelectables(list: searchedHistories, isSelectFirst: true);
    }

    if (searchedPins.isNotEmpty) {
      pinNode.addSelectables(list: searchedPins);
    }

    historyNode.children?.first.isSelected = searchedHistories.isNotEmpty;
    pinNode.children?.first.isSelected =
        searchedHistories.isEmpty && searchedPins.isNotEmpty;
    final nr = TreeNode(
        name: "root",
        isDir: true,
        isSelected: false,
        children: [
          historyNode.copyWith(next: pinNode),
          pinNode.copyWith(prev: historyNode)
        ]);

    return copyWith(currentNode: nr);
  }

  TreeNode currentNodeNode() {
    TreeNode current = currentNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  TreeNode firstChild() {
    TreeNode current = currentNode;

    while (current.children?.isNotEmpty == true) {
      current = current.children!.first;
    }
    return current;
  }

  TopState moveToNext() {
    if (currentNode.isDir) {
      currentNode.isSelected = false;
      if (currentNode.children?.first.isDir == true) {
        return copyWith(currentNode: currentNode.children?.first).moveToNext();
      } else {
        currentNode.children?.first.isSelected = true;
        return copyWith(currentNode: currentNode.children?.first);
      }
    } else {
      currentNode.isSelected = false;
      currentNode.next?.isSelected = true;

      if (currentNode.next != null) {
        // dir->fileのとき
        return copyWith(currentNode: currentNode.next);
      } else {
        return copyWith(currentNode: currentNode.parent?.next).moveToNext();
      }
    }
  }

  void updateCurrentNode() {
    currentNode.isSelected = false;
  }

  TopState moveToPrev() {
    currentNode.isSelected = false;
    currentNode.prev?.isSelected = true;

    return copyWith(currentNode: currentNode.prev);
  }
}
