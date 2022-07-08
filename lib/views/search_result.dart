import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../color.dart';
import '../models/tree_node.dart';
import '../providers/top_state_provider.dart';
import '../types.dart';
import 'intent.dart';
import 'key_set.dart';

class SearchResultView extends ConsumerWidget {
  final FocusNode searchResultFocusNode;
  final TreeNode2VoidFunc handleSearchResultSelect;
  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  final VoidCallback handleSearchFormFocused;
  const SearchResultView(
      {Key? key,
      required this.handleListUp,
      required this.handleListDown,
      required this.handleSearchFormFocused,
      required this.handleSearchResultSelect,
      required this.searchResultFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TreeNode> children =
        ref.watch(topStateProvider).searchResultRoot.children ?? [];
    return FocusableActionDetector(
        focusNode: searchResultFocusNode,
        shortcuts: {
          listViewUpKeySet: ListViewUpIntent(),
          listViewDownKeySet: ListViewDownIntent(),
          searchKeySet: SearchIntent(),
        },
        actions: {
          ListViewUpIntent: CallbackAction(onInvoke: (e) => handleListUp()),
          ListViewDownIntent: CallbackAction(onInvoke: (e) => handleListDown()),
          SearchIntent:
              CallbackAction(onInvoke: (e) => handleSearchFormFocused()),
        },
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, parentIndex) => Column(children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      color: side2ndBackground,
                      alignment: Alignment.centerLeft,
                      child: Text(
                          style: MacosTheme.of(context).typography.title1,
                          children[parentIndex].name)),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, childIndex) => GestureDetector(
                          onTap: () {
                            final item =
                                children[parentIndex].children?[childIndex];
                            handleSearchResultSelect.call(item!);
                          },
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(24, 4, 4, 4),
                              height: 50,
                              color: children[parentIndex]
                                          .children?[childIndex]
                                          .isSelected ??
                                      false
                                  ? side2ndBackgroundSelect
                                  : side2ndBackground,
                              child: Text(
                                  maxLines: 2,
                                  style: MacosTheme.of(context)
                                      .typography
                                      .headline,
                                  children[parentIndex]
                                          .children?[childIndex]
                                          .listText ??
                                      "way"))),
                      separatorBuilder: (context, index) =>
                          const Divider(color: dividerColor, height: 0.5),
                      itemCount: children[parentIndex].children?.length ?? 0)
                ]),
            separatorBuilder: (context, index) =>
                const Divider(color: dividerColor, height: 0.5),
            itemCount: children.length));
  }
}
