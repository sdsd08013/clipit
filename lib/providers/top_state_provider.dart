import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/offset_notifier.dart';
import '../controllers/top_state_notifier.dart';
import '../states/top_state.dart';

final topStateProvider =
    StateNotifierProvider<TopStateNotifier, TopState>((ref) {
  return TopStateNotifier();
});
