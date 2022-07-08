import 'package:clipit/models/tree_node.dart';
import 'package:state_notifier/state_notifier.dart';

import '../models/history.dart';
import '../models/pin.dart';
import '../models/side_type.dart';
import '../models/trash.dart';
import '../states/top_state.dart';

class TopStateNotifier extends StateNotifier<TopState> {
  TopStateNotifier()
      : super(TopState(
            listCurrentNode: TreeNode(
                name: "root", isDir: true, isSelected: false, children: []),
            searchResultCurrentNode: TreeNode(
                name: "root",
                isDir: true,
                isSelected: false,
                children: [
                  TreeNode(
                      name: "history",
                      isDir: true,
                      isSelected: false,
                      children: []),
                  TreeNode(
                      name: "pin", isDir: true, isSelected: false, children: [])
                ]),
            type: ScreenType.CLIP,
            showSearchBar: false,
            showSearchResult: false));

  void moveToNextList() {
    state = state.moveToNextList();
  }

  void moveToPrevList() {
    state = state.moveToPrevList();
  }

  void moveToNextSearchResult() {
    state = state.moveToNextSearchResult();
  }

  void moveToPrevSearchResult() {
    state = state.moveToPrevSearchResult();
  }

  void selectFirstItem() {
    state.listCurrentNode.isSelected = false;
    state.currentDirNodes.first.isSelected = true;
    state = state.copyWith(listCurrentNode: state.currentDirNodes.first);
  }

  void selectLastItem() {
    state.listCurrentNode.isSelected = false;
    state.currentDirNodes.last.isSelected = true;
    state = state.copyWith(listCurrentNode: state.currentDirNodes.last);
  }

  void moveToTargetNode(TreeNode target) {
    state.listCurrentNode.isSelected = false;
    target.isSelected = true;
    state = state.copyWith(
        listCurrentNode: target,
        searchResultCurrentNode: null,
        showSearchResult: false,
        showSearchBar: false);
  }

  void selectTargetNode(TreeNode target) {
    state.listCurrentNode.isSelected = false;
    target.isSelected = true;
    state = state.copyWith(listCurrentNode: target);
  }

  void retlieveTree(HistoryList histories, PinList pins, TrashList trashes) {
    state = state
        .copyWith(histories: histories, pins: pins, trashes: trashes)
        .buildTree(histories, pins, trashes)
        .selectFirstNode();
  }

  void selectFirstNode() {
    state = state.selectFirstNode();
  }

  void insertHistoryToHead(History history) {}

  void changeType(ScreenType type) {
    state = state.copyWith(type: type);
  }

  void deleteHistory(History history) {}

  void deleteCurrentNode() {
    final prev = state.listCurrentNode.prev;
    final next = state.listCurrentNode.next;
    prev?.next = next;
    next?.prev = prev;
    state.listCurrentNode.parent?.children?.remove(state.listCurrentNode);
    prev?.isSelected = true;
    state = state.copyWith(listCurrentNode: prev);
  }

  void insertPinToHead(Pin pin) {}

  void archiveHistory(History history) {}

  void searchSelectables(String text) {
    state.search(text).then((value) {
      state = value.copyWith(showSearchResult: true).selectFirstNode();
    });
  }

  void updateSearchBarVisibility(bool isVisible) {
    state = state.copyWith(showSearchBar: isVisible);
  }

  void moveToNext() {
    state = state.moveToNext();
  }

  void moveToPrev() {
    state = state.moveToPrev();
  }
}
