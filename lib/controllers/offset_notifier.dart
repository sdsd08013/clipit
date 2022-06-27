import 'package:state_notifier/state_notifier.dart';

class OffsetNotifier extends StateNotifier<double> {
  OffsetNotifier() : super(0);

  void update(double offset) {
    state = offset;
  }
}
