import 'package:state_notifier/state_notifier.dart';

import '../models/history.dart';
import '../models/pin.dart';
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
            searchResults: [],
            type: ScreenType.CLIP));

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

  void addHistories(HistoryList histories) {
    state = state.copyWith(histories: histories);
  }

  void addPins(PinList pins) {
    state = state.copyWith(pins: pins);
  }
}
