import 'package:clipit/models/history.dart';
import 'package:clipit/models/tree_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:clipit/models/selectable.dart';
import 'package:clipit/models/side_type.dart';

import '../models/pin.dart';
import '../models/trash.dart';

@immutable
class TopState {
  final SelectableList histories;
  final SelectableList pins;
  final SelectableList trashes;
  final TreeNode currentListNode;
  final TreeNode currentNode;
  final ScreenType type;
  final bool showSearchBar;
  final bool showSearchResult;

  const TopState(
      {required this.histories,
      required this.pins,
      required this.trashes,
      required this.type,
      required this.showSearchBar,
      required this.showSearchResult,
      required this.currentListNode,
      required this.currentNode});

  TopState copyWith({
    SelectableList? histories,
    SelectableList? pins,
    SelectableList? trashes,
    List<SelectableList>? searchResults,
    ScreenType? type,
    bool? showSearchBar,
    bool? showSearchResult,
    TreeNode? currentListNode,
    TreeNode? currentNode,
  }) {
    return TopState(
        histories: histories ?? this.histories,
        pins: pins ?? this.pins,
        trashes: trashes ?? this.trashes,
        type: type ?? this.type,
        showSearchBar: showSearchBar ?? this.showSearchBar,
        showSearchResult: showSearchResult ?? this.showSearchResult,
        currentListNode: currentListNode ?? this.currentListNode,
        currentNode: currentNode ?? this.currentNode);
  }

  TreeNode get root {
    TreeNode current = currentNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  TreeNode get root2 {
    TreeNode current = currentListNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  List<TreeNode> get currentDirNodes {
    root2;
    if (type == ScreenType.CLIP) {
      return root2.children?[0].children ?? [];
    } else if (type == ScreenType.PINNED) {
      return root2.children?[1].children ?? [];
    } else if (type == ScreenType.TRASH) {
      return root2.children?[2].children ?? [];
    } else {
      return root2.children?[0].children ?? [];
    }
  }

  List<TreeNode> get historyNodes {
    return root2.children?[0].children ?? [];
  }

  List<TreeNode> get pinNodes {
    return root2.children?[1].children ?? [];
  }

  SelectableList get currentItems {
    if (type == ScreenType.CLIP) {
      root.children?[0].children;
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
    return currentListNode.sibilings.indexOf(currentListNode);
  }

  TopState decrementCurrentItems() {
    return moveToPrev();
    // if (type == ScreenType.CLIP) {
    //   return copyWith(histories: histories.decrementIndex());
    // } else if (type == ScreenType.PINNED) {
    //   return copyWith(pins: pins.decrementIndex());
    // } else if (type == ScreenType.TRASH) {
    //   return copyWith(trashes: trashes.decrementIndex());
    // } else {
    //   return copyWith(histories: histories.decrementIndex());
    // }
  }

  TopState incrementCurrentItems() {
    return moveToNext();
    /*
    if (type == ScreenType.CLIP) {
      return copyWith(histories: histories.incrementIndex());
    } else if (type == ScreenType.PINNED) {
      return copyWith(pins: pins.incrementIndex());
    } else if (type == ScreenType.TRASH) {
      return copyWith(trashes: trashes.incrementIndex());
    } else {
      return copyWith(histories: histories.incrementIndex());
    }
    */
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

  TopState selectFirstNode() {
    if (root2.children?.first.children?.isNotEmpty == true) {
      return copyWith(currentListNode: root2.children?.first?.children?.first);
    } else {
      return copyWith();
    }
  }

  TopState buildTree(HistoryList histories, PinList pins, TrashList trashes) {
    final historyNode =
        TreeNode(name: "history", isDir: true, isSelected: false, children: []);
    historyNode.addSelectables(list: histories.value, isSelectFirst: true);

    final pinNode =
        TreeNode(name: "pin", isDir: true, isSelected: false, children: []);
    pinNode.addSelectables(list: pins.value);

    final trashNode =
        TreeNode(name: "trash", isDir: true, isSelected: false, children: []);
    trashNode.addSelectables(list: trashes.value);

    return copyWith(
        currentListNode: root2
            .addChild(historyNode.copyWith(next: pinNode, parent: root2))
            .addChild(pinNode.copyWith(
                next: trashNode, prev: historyNode, parent: root2))
            .addChild(trashNode.copyWith(prev: pinNode, parent: root2)));
  }

  TopState buildHistoryTree(HistoryList histories) {
    final historyNode =
        TreeNode(name: "history", isDir: true, isSelected: false, children: []);
    historyNode.addSelectables(list: histories.value);
    return copyWith(currentListNode: root2.addChild(historyNode));
  }

  TopState buildPinTree(PinList pins) {
    final pinNode =
        TreeNode(name: "pin", isDir: true, isSelected: false, children: []);
    pinNode.addSelectables(list: histories.value);
    return copyWith(currentListNode: root2.addChild(pinNode));
  }

  TopState buildTrashTree(TrashList trashes) {
    final trashNode =
        TreeNode(name: "trash", isDir: true, isSelected: false, children: []);
    trashNode.addSelectables(list: trashes.value);
    return copyWith(currentListNode: root2.addChild(trashNode));
  }

  Future<List<TreeNode>> searchHistories(String text) async {
    return historyNodes
        .where((element) => element.listText.contains(text))
        .toList();
  }

  Future<List<TreeNode>> searchPins(String text) async {
    return pinNodes
        .where((element) => element.listText.contains(text))
        .toList();
  }

  Future<TopState> getSearchResult(String text) async {
    final searchedHistories = historyNodes
        .where((element) => element.listText.contains(text))
        .toList();
    final searchedPins =
        pinNodes.where((element) => element.listText.contains(text)).toList();

    final nr =
        TreeNode(name: "root", isDir: true, isSelected: false, children: []);

    final historyNode =
        TreeNode(name: "history", isDir: true, isSelected: false, children: []);
    final pinNode =
        TreeNode(name: "pin", isDir: true, isSelected: false, children: []);

    nr.children = [historyNode, pinNode];
    historyNode.parent = nr;
    pinNode.parent = nr;
    historyNode.next = pinNode;
    pinNode.prev = historyNode;

    if (searchedHistories.isNotEmpty) {
      historyNode.addNodes(list: searchedHistories, isSelectFirst: true);
    }

    if (searchedPins.isNotEmpty) {
      pinNode.addNodes(list: searchedPins);
    }
    historyNode.children?.last.next = pinNode.children?.first;
    pinNode.children?.first.prev = historyNode.children?.last;

    historyNode.children?.first.isSelected = searchedHistories.isNotEmpty;
    pinNode.children?.first.isSelected =
        searchedHistories.isEmpty && searchedPins.isNotEmpty;

    return copyWith(currentNode: historyNode.children?.first);
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

  void updateCurrentNode() {
    currentNode.isSelected = false;
  }

  TopState moveToNext() {
    if (currentListNode.next == null) {
      return copyWith(currentListNode: currentListNode);
    }

    currentListNode.isSelected = false;
    currentListNode.next?.isSelected = true;

    if (currentListNode.isDir) {
      return copyWith(currentListNode: currentListNode.next).moveToNext();
    } else {
      if (currentListNode.next != null) {
        // dir->fileのとき
        return copyWith(currentListNode: currentListNode.next);
      } else {
        return copyWith(currentListNode: currentListNode);
      }
    }
  }

  TopState moveToPrev() {
    if (currentListNode.prev == null) {
      return copyWith(currentListNode: currentListNode);
    }

    currentListNode.isSelected = false;
    currentListNode.prev?.isSelected = true;
    if (currentListNode.isDir) {
      return copyWith(currentListNode: currentListNode.children?.last)
          .moveToPrev();
    } else {
      if (currentListNode.prev != null) {
        return copyWith(currentListNode: currentListNode.prev);
      } else {
        return copyWith(currentListNode: currentListNode);
      }
    }
  }
}
