import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../models/selectable.dart';
import '../models/side_type.dart';
import '../providers/offset_provider.dart';
import 'intent.dart';
import 'key_set.dart';

typedef Int2VoidFunc = void Function(int);
typedef Selectable2VoidFunc = void Function(Selectable);
typedef Bool2VoidFunc = void Function(bool);
typedef String2VoidFunc = void Function(String);
typedef ScreenType2VoidFunc = void Function(ScreenType);

class ContentsListView extends ConsumerWidget {
  final ScrollController controller;
  final Int2VoidFunc onItemTap;
  final List<Selectable> items;
  final FocusNode listFocusNode;
  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  final VoidCallback handleTapCopyToClipboard;
  final VoidCallback handleListViewDeleteTap;
  final VoidCallback handleSearchFormFocused;
  final VoidCallback handleListViewUpToTop;
  final VoidCallback handleListViewDownToBottom;

  ContentsListView(
      {required this.controller,
      required this.items,
      required this.listFocusNode,
      required this.handleListUp,
      required this.handleListDown,
      required this.handleTapCopyToClipboard,
      required this.handleListViewDeleteTap,
      required this.handleSearchFormFocused,
      required this.handleListViewUpToTop,
      required this.handleListViewDownToBottom,
      required this.onItemTap});

  final UniqueKey key1 = UniqueKey();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    const ratio1 = 0.15;
    const ratio2 = 0.85;
    const ratio3 = 0.3;
    const ratio4 = 0.7;
    double offset = ref.watch(offsetProvider);
    return FocusableActionDetector(
        autofocus: true,
        focusNode: listFocusNode,
        shortcuts: {
          listViewUpKeySet: ListViewUpIntent(),
          listViewDownKeySet: ListViewDownIntent(),
          listViewItemCopyKeySet: ListViewItemCopyIntent(),
          listViewDeleteKeySet: ListViewItemDeleteIntent(),
          searchKeySet: SearchIntent(),
          listViewUpToTopKeySet: ListViewUpToTopIntent(),
          listViewDownToBottomKeySet: ListViewDownToBottomIntent(),
        },
        actions: {
          ListViewUpIntent: CallbackAction(onInvoke: (e) {
            handleListUp();
          }),
          ListViewDownIntent: CallbackAction(onInvoke: (e) {
            handleListUp();
            handleListDown();
          }),
          ListViewItemCopyIntent:
              CallbackAction(onInvoke: (e) => handleTapCopyToClipboard()),
          ListViewItemDeleteIntent:
              CallbackAction(onInvoke: (e) => handleListViewDeleteTap()),
          SearchIntent:
              CallbackAction(onInvoke: (e) => handleSearchFormFocused()),
          ListViewUpToTopIntent:
              CallbackAction(onInvoke: (e) => handleListViewUpToTop()),
          ListViewDownToBottomIntent:
              CallbackAction(onInvoke: (e) => handleListViewDownToBottom())
        },
        child: Container(
            color: side2ndBackground,
            width: (appWidth * ratio2 + offset) * ratio3,
            child: ListView.separated(
              controller: controller,
              itemBuilder: (context, index) => GestureDetector(
                  key: key1,
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
