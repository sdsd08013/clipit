import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../models/selectable.dart';
import '../models/side_type.dart';
import 'package:markdown/markdown.dart' as md;

import '../models/tree_node.dart';
import '../providers/offset_provider.dart';
import '../providers/top_state_provider.dart';

class MarkdownView extends ConsumerWidget {
  // TODO: focusnodeを渡す!!!!!!!!!!!!!!!!!
  final FocusNode markdownFocusNode;
  const MarkdownView({Key? key, required this.markdownFocusNode})
      : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    const ratio2 = 0.85;
    const ratio4 = 0.7;
    double offset = ref.watch(offsetProvider);
    TreeNode node = ref.watch(topStateProvider.notifier).state.listCurrentNode;

    return Container(
        decoration: const BoxDecoration(
          color: markdownBackground,
        ),
        alignment: Alignment.topLeft,
        width: (appWidth * ratio2 + offset) * ratio4,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: SelectableText(
              node.item?.plainText ?? "",
              style: const TextStyle(
                  color: textColor, fontFamily: "RictyDiminished"),
            ))
        // child: MarkdownBody(
        //   selectable: true,
        //   builders: {
        //     'pre': CustomBlockBuilder(),
        //   },
        //   styleSheet: MarkdownStyleSheet(
        //       h1: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished"),
        //       h2: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished"),
        //       h3: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished"),
        //       h4: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished"),
        //       h5: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished"),
        //       h6: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished"),
        //       p: const TextStyle(
        //           color: textColor, fontFamily: "RictyDiminished", height: 1.2),
        //       pPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        //       h1Padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        //       h2Padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        //       img: const TextStyle(fontSize: 10),
        //       code: const TextStyle(
        //           color: codeText,
        //           backgroundColor: codeBackground,
        //           fontFamily: "RictyDiminished")),
        //   data: node.item?.mdText ?? "",
        // )
        );
  }
}
