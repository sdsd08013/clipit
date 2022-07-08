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
  final TreeNode listCurrentNode;
  final TreeNode searchListCurrentNode;
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
      required this.listCurrentNode,
      required this.searchListCurrentNode});

  TopState copyWith({
    SelectableList? histories,
    SelectableList? pins,
    SelectableList? trashes,
    List<SelectableList>? searchResults,
    ScreenType? type,
    bool? showSearchBar,
    bool? showSearchResult,
    TreeNode? listCurrentNode,
    TreeNode? searchListCurrentNode,
  }) {
    return TopState(
        histories: histories ?? this.histories,
        pins: pins ?? this.pins,
        trashes: trashes ?? this.trashes,
        type: type ?? this.type,
        showSearchBar: showSearchBar ?? this.showSearchBar,
        showSearchResult: showSearchResult ?? this.showSearchResult,
        listCurrentNode: listCurrentNode ?? this.listCurrentNode,
        searchListCurrentNode:
            searchListCurrentNode ?? this.searchListCurrentNode);
  }

  TreeNode get root {
    TreeNode current = listCurrentNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  TreeNode get root2 {
    TreeNode current = listCurrentNode;
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
    return listCurrentNode.sibilings.indexOf(listCurrentNode);
  }

  TopState decrementCurrentItems() {
    return moveToPrev();
  }

  TopState incrementCurrentItems() {
    return moveToNext();
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
      return copyWith(listCurrentNode: root2.children?.first?.children?.first);
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
        listCurrentNode: root2
            .addChild(historyNode.copyWith(next: pinNode, parent: root2))
            .addChild(pinNode.copyWith(
                next: trashNode, prev: historyNode, parent: root2))
            .addChild(trashNode.copyWith(prev: pinNode, parent: root2)));
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

    return copyWith(searchListCurrentNode: historyNode.children?.first);
  }

  TopState moveToNext() {
    if (listCurrentNode.next == null) {
      return copyWith(listCurrentNode: listCurrentNode);
    }

    listCurrentNode.isSelected = false;
    listCurrentNode.next?.isSelected = true;

    if (listCurrentNode.isDir) {
      return copyWith(listCurrentNode: listCurrentNode.next).moveToNext();
    } else {
      if (listCurrentNode.next != null) {
        // dir->fileのとき
        return copyWith(listCurrentNode: listCurrentNode.next);
      } else {
        return copyWith(listCurrentNode: listCurrentNode);
      }
    }
  }

  TopState moveToPrev() {
    if (listCurrentNode.prev == null) {
      return copyWith(listCurrentNode: listCurrentNode);
    }

    listCurrentNode.isSelected = false;
    listCurrentNode.prev?.isSelected = true;
    if (listCurrentNode.isDir) {
      return copyWith(listCurrentNode: listCurrentNode.children?.last)
          .moveToPrev();
    } else {
      if (listCurrentNode.prev != null) {
        return copyWith(listCurrentNode: listCurrentNode.prev);
      } else {
        return copyWith(listCurrentNode: listCurrentNode);
      }
    }
  }
}
