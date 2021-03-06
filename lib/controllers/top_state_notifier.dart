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
                name: "root", isDir: true, isSelected: false, children: []),
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

  void updateTargetHistory(result) {}

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
    state.listCurrentNode.unSelect();
    target.select();
    state = state.copyWith(
        listCurrentNode: target,
        searchResultCurrentNode: null,
        showSearchResult: false,
        showSearchBar: false);
  }

  void selectTargetNode(TreeNode target) {
    state.listCurrentNode.unSelect();
    target.select();
    if (target.isDir) {
      target.children?.first.isSelected = true;
      state = state.copyWith(listCurrentNode: target.children?.first);
      // TODO: dirの場合はchild, fileの場合はtarget
    } else {
      state = state.copyWith(listCurrentNode: target);
    }
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

  void insertHistoryToHead(History history) {
    state = state.createHistory(history);
  }

  void deleteHistory(History history) {}

  void deleteCurrentNode() {
    if (state.listCurrentNode.index == 0) {
      final next = state.listCurrentNode.next;
      next?.prev = null;
      state.listCurrentNode.parent?.children?.remove(state.listCurrentNode);
      next?.isSelected = true;
      state = state.copyWith(listCurrentNode: next);
    } else {
      final prev = state.listCurrentNode.prev;
      final next = state.listCurrentNode.next;
      prev?.next = next;
      next?.prev = prev;
      state.listCurrentNode.parent?.children?.remove(state.listCurrentNode);
      prev?.isSelected = true;
      state = state.copyWith(listCurrentNode: prev);
    }
  }

  void insertPinToHead(Pin pin) {}

  void archiveHistory(History history) {}

  void searchTreeNode(String text) {
    state.search(text).then((value) {
      state = value.copyWith(showSearchResult: true).selectFirstNode();
    });
  }

  void updateSearchBarVisibility(bool isVisible) {
    state = state.copyWith(showSearchBar: isVisible);
  }

  void clearSearchResult() {
    state =
        state.copyWith(searchResultCurrentNode: null, showSearchResult: false);
  }
}
