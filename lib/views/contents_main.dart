import 'package:clipit/color.dart';
import 'package:clipit/views/markdown.dart';
import 'package:clipit/views/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/side_type.dart';
import '../providers/offset_provider.dart';
import '../providers/top_state_provider.dart';
import '../states/top_state.dart';
import '../types.dart';
import 'contents_header.dart';
import 'contents_list_view.dart';

class ContentsMainView extends ConsumerWidget {
  final Int2VoidFunc handleListViewItemTap;
  final TreeNode2VoidFunc handleSearchResultSelect;
  final VoidCallback handleArchiveItemTap;
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleDeleteItemTap;
  final VoidCallback handleEditItemTap;

  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  final VoidCallback handleSearchResultUp;
  final VoidCallback handleSearchResultDown;
  final VoidCallback handleTapCopyToClipboard;
  final VoidCallback handleListViewDeleteTap;
  final VoidCallback handleSearchFormFocused;
  final VoidCallback handleListUpToTop;
  final VoidCallback handleListDownToBottom;

  final Bool2VoidFunc handleSearchFormFocusChange;
  final String2VoidFunc handleSearchFormInput;
  final ScrollController controller;
  final FocusNode searchFormFocusNode;
  final FocusNode searchResultFocusNode;
  final FocusNode listFocusNode;

  ContentsMainView(
      {required this.handleArchiveItemTap,
      required this.handleSearchResultSelect,
      required this.handleListViewItemTap,
      required this.handleCopyToClipboardTap,
      required this.handleDeleteItemTap,
      required this.handleEditItemTap,
      required this.handleSearchFormFocusChange,
      required this.handleSearchFormInput,
      required this.handleListUp,
      required this.handleListDown,
      required this.handleSearchResultUp,
      required this.handleSearchResultDown,
      required this.handleTapCopyToClipboard,
      required this.handleListViewDeleteTap,
      required this.handleSearchFormFocused,
      required this.handleListUpToTop,
      required this.handleListDownToBottom,
      required this.controller,
      required this.searchFormFocusNode,
      required this.searchResultFocusNode,
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
              isEditable: topState.type == ScreenType.PINNED,
              searchFormFocusNode: searchFormFocusNode,
              handleSearchFormFocusChange: (hasFocus) =>
                  handleSearchFormFocusChange(hasFocus),
              handleSearchFormInput: (text) => handleSearchFormInput(text),
              handleMoveToPinTap: () => handleArchiveItemTap(),
              handleCopyToClipboardTap: () => handleCopyToClipboardTap(),
              handleMoveToTrashTap: () => handleDeleteItemTap(),
              handleEditItemTap: () => handleEditItemTap()),
          Expanded(
              child: Stack(
            children: [
              topState.currentItems.value.isEmpty
                  ? const Text("item is empty ;(")
                  : Row(children: <Widget>[
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
                          onItemTap: (index) => handleListViewItemTap(index)),
                      MarkdownView()
                    ]),
              Visibility(
                  visible: topState.showSearchResult,
                  child: Container(
                      color: side2ndBackground,
                      height: double.infinity,
                      child: SearchResultView(
                          handleListUp: handleSearchResultUp,
                          handleListDown: handleSearchResultDown,
                          handleSearchFormFocused: handleSearchFormFocused,
                          searchResultFocusNode: searchResultFocusNode,
                          handleSearchResultSelect: handleSearchResultSelect)))
            ],
          ))
        ]));
  }
}
