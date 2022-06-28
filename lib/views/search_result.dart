import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../models/selectable.dart';
import '../providers/top_state_provider.dart';
import 'contents_list_view.dart';
import 'intent.dart';
import 'key_set.dart';

class SearchResultView extends ConsumerWidget {
  final FocusNode searchResultFocusNode;
  final Selectable2VoidFunc onItemTap;
  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  final VoidCallback handleSearchFormFocused;
  const SearchResultView(
      {Key? key,
      required this.handleListUp,
      required this.handleListDown,
      required this.handleSearchFormFocused,
      required this.onItemTap,
      required this.searchResultFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SelectableList> results = ref.watch(topStateProvider).searchResults;
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
              CallbackAction(onInvoke: (e) => print("fooooooooooooooooocus")),
        },
        child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, parentIndex) => Column(children: [
                  Text(results[parentIndex].listTitle),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, childIndex) => GestureDetector(
                          onTap: () {
                            onItemTap
                                .call(results[parentIndex].value[childIndex]);
                          },
                          child: Container(
                              height: 75,
                              padding: const EdgeInsets.all(8),
                              color: results[parentIndex]
                                      .value[childIndex]
                                      .isSelected
                                  ? side2ndBackgroundSelect
                                  : side2ndBackground,
                              child: RichText(
                                text: TextSpan(
                                  text: results[parentIndex]
                                      .value[childIndex]
                                      .plainText,
                                  style: const TextStyle(
                                      color: textColor,
                                      fontFamily: "RictyDiminished"),
                                ),
                              ))),
                      separatorBuilder: (context, childIndex) =>
                          const Divider(color: dividerColor, height: 0.5),
                      itemCount: results[parentIndex].value.length)
                ]),
            itemCount: results.length));
  }
}
