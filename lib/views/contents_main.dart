import 'package:clipit/models/selectable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final Bool2VoidFunc handleSearchFormFocusChange;
  final bool isEditable;
  final bool isSearchable;
  final ScrollController controller;
  final double listWidth;
  final double contentsWidth;
  final SelectableList items;
  final FocusNode searchFocusNode;

  ContentsMainView(
      {required this.handleArchiveItemTap,
      required this.handleListViewItemTap,
      required this.handleCopyToClipboardTap,
      required this.handleDeleteItemTap,
      required this.handleEditItemTap,
      required this.handleSearchFormFocusChange,
      required this.isEditable,
      required this.isSearchable,
      required this.controller,
      required this.listWidth,
      required this.contentsWidth,
      required this.searchFocusNode,
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
          decoration: const BoxDecoration(
            color: markdownBackground,
          ),
          alignment: Alignment.topLeft,
          width: contentsWidth,
          child: Column(children: [
            ContentsHeader(
                isEditable: isEditable,
                isSearchable: isSearchable,
                searchFocusNode: searchFocusNode,
                handleSearchFormFocusChange: (hasFocus) =>
                    handleSearchFormFocusChange(hasFocus),
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
