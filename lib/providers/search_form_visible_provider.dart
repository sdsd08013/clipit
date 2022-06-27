import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/search_form_visible_notifier.dart';

final searchFormVisibleProvider =
    StateNotifierProvider<SearchFormVisibleNotifier, bool>((ref) {
  return SearchFormVisibleNotifier();
});
