import 'package:state_notifier/state_notifier.dart';

class SearchFormVisibleNotifier extends StateNotifier<bool> {
  SearchFormVisibleNotifier() : super(false);

  void update(bool isVisible) {
    state = isVisible;
  }
}
