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
    if (listCurrentNode.isDir) {
      return listCurrentNode.children ?? [];
    } else {
      return listCurrentNode.sibilings;
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

  TopState createHistory(History history) {
    final TreeNode node = TreeNode(
        name: history.subText,
        isSelected: history.isSelected,
        isDir: history.isDir,
        item: history,
        prev: null,
        next: historyNodes.first,
        parent: listRoot.children?[0]);

    historyNodes.first.prev = node;
    listRoot.children?[0].addChildToHead(node);

    listCurrentNode.unSelect();
    node.select();
    return copyWith(listCurrentNode: node);
  }

  TopState updateHistory(text) {
    final node =
        historyNodes.where((element) => element.item?.name == text).firstOrNull;
    listCurrentNode.unSelect();
    node?.select();
    return copyWith(listCurrentNode: node);
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
    final node =
        historyNodes.where((element) => element.item?.name == text).firstOrNull;
    if (node == null) {
      return true;
    } else {
      return node.item?.updatedAt
              .add(const Duration(minutes: 1))
              .isBefore(DateTime.now()) ==
          true;
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
    if (historyNode.children?.isNotEmpty == true) {
      historyNode.children?.first.isSelected = searchedHistories.isNotEmpty;

      if (pinNode.children?.isNotEmpty == true) {
        historyNode.children?.last.next = pinNode.children?.first;
      }
    }
    if (pinNode.children?.isNotEmpty == true) {
      pinNode.children?.first.isSelected =
          searchedHistories.isEmpty && searchedPins.isNotEmpty;

      if (historyNode.children?.isNotEmpty == true) {
        pinNode.children?.first.prev = historyNode.children?.last;
      }
    }

    if (historyNode.children?.isNotEmpty == true) {
      return copyWith(searchResultCurrentNode: historyNode.children?.first);
    } else if (pinNode.children?.isNotEmpty == true) {
      return copyWith(searchResultCurrentNode: pinNode.children?.first);
    } else {
      return copyWith(searchResultCurrentNode: null);
    }
  }
}
