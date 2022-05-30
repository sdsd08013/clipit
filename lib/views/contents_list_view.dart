import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../color.dart';
import '../models/selectable.dart';
import '../models/side_type.dart';

typedef Int2VoidFunc = void Function(int);
typedef Bool2VoidFunc = void Function(bool);
typedef String2VoidFunc = void Function(String);
typedef ScreenType2VoidFunc = void Function(ScreenType);

class ContentsListView extends StatelessWidget {
  final double width;
  final ScrollController controller;
  final Int2VoidFunc onItemTap;
  final List<Selectable> items;
  final FocusNode listFocusNode;
  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  final VoidCallback handleTapCopyToClipboard;
  final VoidCallback handleListViewDeleteTap;
  final VoidCallback handleSearchFormFocused;
  ContentsListView(
      {required this.width,
      required this.controller,
      required this.items,
      required this.listFocusNode,
      required this.handleListUp,
      required this.handleListDown,
      required this.handleTapCopyToClipboard,
      required this.handleListViewDeleteTap,
      required this.handleSearchFormFocused,
      required this.onItemTap});
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
        autofocus: true,
        focusNode: listFocusNode,
        shortcuts: {
          _listViewUpKeySet: _ListViewUpIntent(),
          _listViewDownKeySet: _ListViewDownIntent(),
          _listViewItemCopyKeySet: _ListViewItemCopyIntent(),
          _listViewDeleteKeySet: _ListViewItemDeleteIntent(),
          _searchKeySet: _SearchIntent()
        },
        actions: {
          _ListViewUpIntent: CallbackAction(onInvoke: (e) => handleListUp()),
          _ListViewDownIntent:
              CallbackAction(onInvoke: (e) => handleListDown()),
          _ListViewItemCopyIntent:
              CallbackAction(onInvoke: (e) => handleTapCopyToClipboard()),
          _ListViewItemDeleteIntent:
              CallbackAction(onInvoke: (e) => handleListViewDeleteTap()),
          _SearchIntent:
              CallbackAction(onInvoke: (e) => handleSearchFormFocused())
        },
        child: Container(
            color: side2ndBackground,
            width: width,
            child: ListView.separated(
              controller: controller,
              itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    onItemTap.call(index);
                  },
                  child: Container(
                      height: 75,
                      padding: const EdgeInsets.all(8),
                      color: items[index].isSelected
                          ? side2ndBackgroundSelect
                          : side2ndBackground,
                      child: RichText(
                        text: TextSpan(
                          text: items[index].subText(),
                          style: const TextStyle(
                              color: textColor, fontFamily: "RictyDiminished"),
                        ),
                      ))),
              separatorBuilder: (context, index) =>
                  const Divider(color: dividerColor, height: 0.5),
              itemCount: items.length,
            )));
  }
}

class _ListViewDownIntent extends Intent {}

class _ListViewUpIntent extends Intent {}

class _ListViewItemCopyIntent extends Intent {}

class _ListViewItemDeleteIntent extends Intent {}

class _SearchIntent extends Intent {}

final _listViewDownKeySet = LogicalKeySet(LogicalKeyboardKey.keyJ);
final _listViewUpKeySet = LogicalKeySet(LogicalKeyboardKey.keyK);
final _listViewItemCopyKeySet =
    LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.meta);
final _listViewDeleteKeySet = LogicalKeySet(LogicalKeyboardKey.keyD);
final _searchKeySet = LogicalKeySet(LogicalKeyboardKey.slash);
