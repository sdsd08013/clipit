import 'package:flutter/material.dart';

import '../color.dart';
import '../models/selectable.dart';
import 'contents_list_view.dart';
import 'intent.dart';
import 'key_set.dart';

class SearchResultView extends StatelessWidget {
  List<SelectableList> results;
  final FocusNode searchResultFocusNode;
  final Selectable2VoidFunc onItemTap;
  final VoidCallback handleListUp;
  final VoidCallback handleListDown;
  SearchResultView(
      {Key? key,
      required this.results,
      required this.handleListUp,
      required this.handleListDown,
      required this.onItemTap,
      required this.searchResultFocusNode})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
        focusNode: searchResultFocusNode,
        shortcuts: {
          listViewUpKeySet: ListViewUpIntent(),
          listViewDownKeySet: ListViewDownIntent(),
        },
        actions: {
          ListViewUpIntent: CallbackAction(onInvoke: (e) => handleListUp()),
          ListViewDownIntent: CallbackAction(onInvoke: (e) => handleListDown()),
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
