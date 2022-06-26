import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/offset_notifier.dart';

final offsetProvider = StateNotifierProvider<OffsetNotifier, double>((ref) {
  return OffsetNotifier();
});
