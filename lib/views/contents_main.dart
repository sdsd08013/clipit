import 'package:clipit/models/selectable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../color.dart';
import '../models/side_type.dart';
import 'contents_header.dart';
import 'contents_list_view.dart';
import 'package:markdown/markdown.dart' as md;

class ContentsMainView extends StatelessWidget {
  final Int2VoidFunc handleListViewItemTap;
  final VoidCallback handleArchiveItemTap;
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleDeleteItemTap;
  final VoidCallback handleEditItemTap;
  final bool isEditable;
  final ScrollController controller;
  final double listWidth;
  final double contentsWidth;
  final SelectableList items;

  ContentsMainView(
      {required this.handleArchiveItemTap,
      required this.handleListViewItemTap,
      required this.handleCopyToClipboardTap,
      required this.handleDeleteItemTap,
      required this.handleEditItemTap,
      required this.isEditable,
      required this.controller,
      required this.listWidth,
      required this.contentsWidth,
      required this.items});
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      ContentsListView(
          controller: controller,
          width: listWidth,
          onItemTap: (index) => handleListViewItemTap(index),
          items: items.value),
      Container(
          alignment: Alignment.topLeft,
          width: contentsWidth,
          child: Column(children: [
            ContentsHeader(
                isEditable: isEditable,
                handleMoveToPinTap: () => handleArchiveItemTap(),
                handleCopyToClipboardTap: () => handleCopyToClipboardTap(),
                handleMoveToTrashTap: () => handleDeleteItemTap(),
                handleEditItemTap: () => handleEditItemTap()),
            Expanded(
                child: Markdown(
              controller: ScrollController(),
              shrinkWrap: true,
              selectable: true,
              builders: {
                'pre': CustomBlockBuilder(),
              },
              styleSheet: MarkdownStyleSheet(
                  img: const TextStyle(fontSize: 10),
                  code: const TextStyle(
                      color: codeText, backgroundColor: codeBackground)),
              data: items.currentItem.mdText,
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                [
                  md.EmojiSyntax(),
                  ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                ],
              ),
            ))
          ]))
    ]);
  }
}
