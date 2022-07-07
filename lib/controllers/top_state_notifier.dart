import 'package:clipit/models/directable.dart';
import 'package:clipit/models/tree_node.dart';
import 'package:state_notifier/state_notifier.dart';

import '../models/history.dart';
import '../models/pin.dart';
import '../models/selectable.dart';
import '../models/side_type.dart';
import '../models/trash.dart';
import '../states/top_state.dart';

class TopStateNotifier extends StateNotifier<TopState> {
  TopStateNotifier()
      : super(TopState(
            histories:
                HistoryList(currentIndex: 0, listTitle: "history", value: []),
            pins: PinList(currentIndex: 0, listTitle: "pin", value: []),
            trashes: TrashList(currentIndex: 0, listTitle: "trash", value: []),
            currentNode: TreeNode(
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

  void increment() {
    state = state.incrementCurrentItems();
  }

  void decrement() {
    state = state.decrementCurrentItems();
  }

  void selectFirstItem() {
    state = state.switchCurrentItems(0);
  }

  void selectLastItem() {
    state = state.switchCurrentItems(state.currentItems.value.length - 1);
  }

  void selectTargetItem(int targetIndex) {
    state = state.switchCurrentItems(targetIndex);
  }

  void addHistories(HistoryList histories) {
    state = state.copyWith(histories: histories);
  }

  void addPins(PinList pins) {
    state = state.copyWith(pins: pins);
  }

  void insertHistoryToHead(History history) {
    state = state.copyWith(histories: state.histories.insertToFirst(history));
  }

  void changeType(ScreenType type) {
    state = state.copyWith(type: type);
  }

  void deleteHistory(History history) {
    state =
        state.copyWith(histories: state.histories.deleteTargetHistory(history));
  }

  void deleteCurrentHistory() {
    state = state.copyWith(histories: state.histories.deleteCurrentHistory());
  }

  void insertPinToHead(Pin pin) {
    state = state.copyWith(pins: state.pins.insertToFirst(pin));
  }

  void archiveHistory(History history) {}

  void clearSearchResult() {
    state = state.copyWith(
        searchResults: [], showSearchResult: false, showSearchBar: false);
  }

  void searchSelectables(String text) {
    state.getSearchResult(text).then((value) {
      state = value.copyWith(showSearchResult: true);
    });
  }

  void selectSearchedItem(Selectable item) {
    int index = 0;
    if (item is History) {
      index = state.histories.getTargetIndex(item);
    } else if (item is Pin) {
      index = state.pins.getTargetIndex(item);
    } else if (item is Trash) {
      index = state.trashes.getTargetIndex(item);
    } else {
      index = state.histories.getTargetIndex(item);
    }
    state = state
        .switchCurrentItems(index)
        .copyWith(searchResults: [], showSearchResult: false);
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
