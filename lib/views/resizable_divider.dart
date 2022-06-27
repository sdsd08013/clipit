import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../providers/offset_provider.dart';

class ResizableDivider extends ConsumerWidget {
  double dragStartPos = 0;
  double offset = 0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const ratio1 = 0.15;
    const ratio2 = 0.85;
    const ratio3 = 0.3;
    const ratio4 = 0.7;
    return MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: GestureDetector(
            onHorizontalDragStart: (detail) {
              dragStartPos = detail.globalPosition.dx;
            },
            onHorizontalDragUpdate: (detail) {
              final appWidth = MediaQuery.of(context).size.width;
              double newOffset = dragStartPos - detail.globalPosition.dx;
              if (appWidth * ratio1 < newOffset ||
                  appWidth * ratio1 - newOffset > appWidth) return;

              ref
                  .read(offsetProvider.notifier)
                  .update(dragStartPos - detail.globalPosition.dx);
            },
            child: Container(
              width: 1,
              color: dividerColor,
            )));
  }
}
