import 'package:flutter/cupertino.dart';
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
        child: Markdown(
            controller: ScrollController(),
            shrinkWrap: true,
            selectable: true,
            builders: {
              'pre': CustomBlockBuilder(),
            },
            styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                    color: textColor, fontFamily: "RictyDiminished"),
                h2: const TextStyle(
                    color: textColor, fontFamily: "RictyDiminished"),
                h3: const TextStyle(
                    color: textColor, fontFamily: "RictyDiminished"),
                h4: const TextStyle(
                    color: textColor, fontFamily: "RictyDiminished"),
                h5: const TextStyle(
                    color: textColor, fontFamily: "RictyDiminished"),
                h6: const TextStyle(
                    color: textColor, fontFamily: "RictyDiminished"),
                p: const TextStyle(
                    color: textColor,
                    fontFamily: "RictyDiminished",
                    height: 1.2),
                pPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                h1Padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                h2Padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                img: const TextStyle(fontSize: 10),
                code: const TextStyle(
                    color: codeText,
                    backgroundColor: codeBackground,
                    fontFamily: "RictyDiminished")),
            data: (node.item as Selectable).mdText,
            extensionSet: md.ExtensionSet(
              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
              [
                md.EmojiSyntax(),
                ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
              ],
            )));
  }
}
