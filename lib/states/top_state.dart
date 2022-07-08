import 'package:clipit/models/history.dart';
import 'package:clipit/models/tree_node.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:clipit/models/selectable.dart';
import 'package:clipit/models/side_type.dart';
import 'package:flutter/material.dart';

import '../models/pin.dart';
import '../models/trash.dart';

@immutable
class TopState {
  final TreeNode listCurrentNode;
  final TreeNode searchResultCurrentNode;
  final ScreenType type;
  final bool showSearchBar;
  final bool showSearchResult;

  const TopState(
      {required this.type,
      required this.showSearchBar,
      required this.showSearchResult,
      required this.listCurrentNode,
      required this.searchResultCurrentNode});

  TopState copyWith({
    SelectableList? histories,
    SelectableList? pins,
    SelectableList? trashes,
    ScreenType? type,
    bool? showSearchBar,
    bool? showSearchResult,
    TreeNode? listCurrentNode,
    TreeNode? searchResultCurrentNode,
  }) {
    return TopState(
        type: type ?? this.type,
        showSearchBar: showSearchBar ?? this.showSearchBar,
        showSearchResult: showSearchResult ?? this.showSearchResult,
        listCurrentNode: listCurrentNode ?? this.listCurrentNode,
        searchResultCurrentNode:
            searchResultCurrentNode ?? this.searchResultCurrentNode);
  }

  TreeNode get listRoot {
    TreeNode current = listCurrentNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  TreeNode get searchResultRoot {
    TreeNode current = searchResultCurrentNode;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  List<TreeNode> get currentDirNodes {
    if (type == ScreenType.CLIP) {
      return listRoot.children?[0].children ?? [];
    } else if (type == ScreenType.PINNED) {
      return listRoot.children?[1].children ?? [];
    } else if (type == ScreenType.TRASH) {
      return listRoot.children?[2].children ?? [];
    } else {
      return listRoot.children?[0].children ?? [];
    }
  }

  List<TreeNode> get firstHierarchicalDirs {
    return listRoot.children ?? [];
  }

  List<TreeNode> get historyNodes {
    return listRoot.children?[0].children ?? [];
  }

  List<TreeNode> get pinNodes {
    return listRoot.children?[1].children ?? [];
  }

  Selectable? get currentItem => (listCurrentNode.item as Selectable);

  int get currentIndex {
    return listCurrentNode.sibilings.indexOf(listCurrentNode);
  }

  TopState moveToPrevList() {
    return copyWith(listCurrentNode: listCurrentNode.moveToPrev());
  }

  TopState moveToNextList() {
    return copyWith(listCurrentNode: listCurrentNode.moveToNext());
  }

  TopState moveToPrevSearchResult() {
    return copyWith(
        searchResultCurrentNode: searchResultCurrentNode.moveToPrev());
  }

  TopState moveToNextSearchResult() {
    return copyWith(
        searchResultCurrentNode: searchResultCurrentNode.moveToNext());
  }

  bool isPinExist(String text) =>
      pinNodes.where((element) => element.item?.name == text).isNotEmpty;
  bool isHistoryExist(String text) =>
      historyNodes.where((element) => element.item?.name == text).isNotEmpty;
  bool shouldUpdateHistory(String text) {
    final clip =
        historyNodes.where((element) => element.item?.name == text).firstOrNull;
    if (clip == null) {
      return true;
    } else {
      return (clip.item as Selectable)
          .updatedAt
          .add(const Duration(minutes: 1))
          .isBefore(DateTime.now());
    }
  }

  TopState selectFirstNode() {
    if (listRoot.children?.first.children?.isNotEmpty == true) {
      listCurrentNode.unSelect();
      listRoot.children?.first.children?.first?.select();
      return copyWith(
          listCurrentNode: listRoot.children?.first.children?.first);
    } else {
      return copyWith();
    }
  }

  TopState buildTree(HistoryList histories, PinList pins, TrashList trashes) {
    final historyNode = TreeNode(
        name: "history",
        isDir: true,
        isSelected: false,
        icon: Icons.history,
        children: []);
    historyNode.addSelectables(list: histories.value);

    final pinNode = TreeNode(
        name: "pin",
        isDir: true,
        isSelected: false,
        icon: Icons.push_pin_sharp,
        children: []);
    pinNode.addSelectables(list: pins.value);

    final trashNode = TreeNode(
        name: "trash",
        isDir: true,
        isSelected: false,
        icon: Icons.delete,
        children: []);
    trashNode.addSelectables(list: trashes.value);

    return copyWith(
        listCurrentNode: listCurrentNode
            .addChild(
                historyNode.copyWith(next: pinNode, parent: searchResultRoot))
            .addChild(pinNode.copyWith(
                next: trashNode, prev: historyNode, parent: searchResultRoot))
            .addChild(
                trashNode.copyWith(prev: pinNode, parent: searchResultRoot)));
  }

  Future<TopState> search(String text) async {
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
      historyNode.addNodes(list: searchedHistories);
    }

    if (searchedPins.isNotEmpty) {
      pinNode.addNodes(list: searchedPins);
    }
    historyNode.children?.last.next = pinNode.children?.first;
    pinNode.children?.first.prev = historyNode.children?.last;

    historyNode.children?.first.isSelected = searchedHistories.isNotEmpty;
    pinNode.children?.first.isSelected =
        searchedHistories.isEmpty && searchedPins.isNotEmpty;

    return copyWith(searchResultCurrentNode: historyNode.children?.first);
  }
}
