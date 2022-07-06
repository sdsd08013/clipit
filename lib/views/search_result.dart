import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../models/selectable.dart';
import '../models/tree_node.dart';
import '../providers/top_state_provider.dart';
import 'contents_list_view.dart';
import 'intent.dart';
import 'key_set.dart';

class SearchResultView extends ConsumerWidget {
  final FocusNode searchResultFocusNode;
  final Selectable2VoidFunc handleSearchResultSelect;
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
    List<TreeNode> children = ref.watch(topStateProvider).root.children ?? [];
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
                  Text(children[parentIndex].name),
                  ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, childIndex) => Container(
                          height: 50,
                          color: children[parentIndex]
                                      .children?[childIndex]
                                      .isSelected ??
                                  false
                              ? side2ndBackgroundSelect
                              : side2ndBackground,
                          child: Text(children[parentIndex]
                                  .children?[childIndex]
                                  .listText ??
                              "way")),
                      itemCount: children[parentIndex].children?.length ?? 0)
                ]),
            separatorBuilder: (context, index) =>
                const Divider(color: dividerColor, height: 0.5),
            itemCount: children.length));

    // child: ListView.separated(
    //     shrinkWrap: true,
    //     itemBuilder: (context, parentIndex) => ListView.builder(
    //         itemBuilder: (context, childIndex) =>
    //             children[parentIndex].children![childIndex].isDir
    //                 ? Text(children[parentIndex].children![childIndex].name)
    //                 : Container(
    //                     height: 75,
    //                     padding: const EdgeInsets.all(8),
    //                     color: children[parentIndex]
    //                             .children![childIndex]
    //                             .isSelected
    //                         ? side2ndBackgroundSelect
    //                         : side2ndBackground,
    //                     child: RichText(
    //                       text: TextSpan(
    //                         text: children[parentIndex]
    //                             .children![childIndex]
    //                             .listText,
    //                         style: const TextStyle(
    //                             color: textColor,
    //                             fontFamily: "RictyDiminished"),
    //                       ),
    //                     )),
    //         itemCount: children[parentIndex].children?.length),
    //     separatorBuilder: (context, index) =>
    //         const Divider(color: dividerColor, height: 0.5),
    //     itemCount: children.length));
  }
}
