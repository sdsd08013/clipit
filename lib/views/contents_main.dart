import 'package:clipit/models/selectable.dart';
import 'package:clipit/views/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../models/side_type.dart';
import '../providers/offset_provider.dart';
import '../providers/top_state_provider.dart';
import '../states/top_state.dart';
import 'contents_header.dart';
import 'contents_list_view.dart';
import 'package:markdown/markdown.dart' as md;

class ContentsMainView extends ConsumerWidget {
  final Int2VoidFunc handleListViewItemTap;
  final Selectable2VoidFunc handleSearchedItemTap;
  final VoidCallback handleArchiveItemTap;
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleDeleteItemTap;
  final VoidCallback handleEditItemTap;

  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  final VoidCallback handleTapCopyToClipboard;
  final VoidCallback handleListViewDeleteTap;
  final VoidCallback handleSearchFormFocused;
  final VoidCallback handleListUpToTop;
  final VoidCallback handleListDownToBottom;

  final Bool2VoidFunc handleSearchFormFocusChange;
  final String2VoidFunc handleSearchFormInput;
  final bool isEditable;
  final bool isSearchable;
  final bool showSearchResult;
  final ScrollController controller;
  final List<SelectableList> searchResults;
  final FocusNode searchFormFocusNode;
  final FocusNode searchResultFocusNode;
  final FocusNode listFocusNode;
  final ScreenType type;

  ContentsMainView(
      {required this.handleArchiveItemTap,
      required this.handleSearchedItemTap,
      required this.handleListViewItemTap,
      required this.handleCopyToClipboardTap,
      required this.handleDeleteItemTap,
      required this.handleEditItemTap,
      required this.handleSearchFormFocusChange,
      required this.handleSearchFormInput,
      required this.handleListUp,
      required this.handleListDown,
      required this.handleTapCopyToClipboard,
      required this.handleListViewDeleteTap,
      required this.handleSearchFormFocused,
      required this.handleListUpToTop,
      required this.handleListDownToBottom,
      required this.isEditable,
      required this.isSearchable,
      required this.showSearchResult,
      required this.controller,
      required this.searchFormFocusNode,
      required this.searchResultFocusNode,
      required this.type,
      required this.searchResults,
      required this.listFocusNode});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    const ratio2 = 0.85;
    const ratio4 = 0.7;
    double offset = ref.watch(offsetProvider);
    TopState topState = ref.watch(topStateProvider);

    return Container(
        alignment: Alignment.topLeft,
        width: appWidth * ratio2 + offset,
        child: Column(children: [
          ContentsHeader(
              isEditable: isEditable,
              isSearchable: isSearchable,
              searchFormFocusNode: searchFormFocusNode,
              handleSearchFormFocusChange: (hasFocus) =>
                  handleSearchFormFocusChange(hasFocus),
              handleSearchFormInput: (text) => handleSearchFormInput(text),
              handleMoveToPinTap: () => handleArchiveItemTap(),
              handleCopyToClipboardTap: () => handleCopyToClipboardTap(),
              handleMoveToTrashTap: () => handleDeleteItemTap(),
              handleEditItemTap: () => handleEditItemTap()),
          Expanded(child: (() {
            if (showSearchResult) {
              return SearchResultView(
                  key: GlobalKey(),
                  handleListUp: handleListUp,
                  handleListDown: handleListDown,
                  searchResultFocusNode: searchResultFocusNode,
                  results: searchResults,
                  onItemTap: handleSearchedItemTap);
            } else {
              if (topState.currentItems.value.isEmpty) {
                return const Text("item is empty ;(");
              } else {
                return Row(children: <Widget>[
                  ContentsListView(
                      controller: controller,
                      listFocusNode: listFocusNode,
                      handleListUp: handleListUp,
                      handleListDown: handleListDown,
                      handleListViewUpToTop: handleListUpToTop,
                      handleListViewDownToBottom: handleListDownToBottom,
                      handleListViewDeleteTap: handleListViewDeleteTap,
                      handleTapCopyToClipboard: handleTapCopyToClipboard,
                      handleSearchFormFocused: handleSearchFormFocused,
                      onItemTap: (index) => handleListViewItemTap(index),
                      items: topState.currentItems.value),
                  Container(
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
                                  color: textColor,
                                  fontFamily: "RictyDiminished"),
                              h2: const TextStyle(
                                  color: textColor,
                                  fontFamily: "RictyDiminished"),
                              h3: const TextStyle(
                                  color: textColor,
                                  fontFamily: "RictyDiminished"),
                              h4: const TextStyle(
                                  color: textColor,
                                  fontFamily: "RictyDiminished"),
                              h5: const TextStyle(
                                  color: textColor,
                                  fontFamily: "RictyDiminished"),
                              h6: const TextStyle(
                                  color: textColor,
                                  fontFamily: "RictyDiminished"),
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
                          data: topState.currentItems.currentItem.mdText,
                          extensionSet: md.ExtensionSet(
                            md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                            [
                              md.EmojiSyntax(),
                              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                            ],
                          )))
                ]);
              }
            }
          })())
        ]));
  }
}
