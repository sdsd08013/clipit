import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../models/selectable.dart';

class SearchResultView extends StatelessWidget {
  List<SelectableList> results;
  SearchResultView({required this.results});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, parentIndex) => Column(children: [
              Text(results[parentIndex].listTitle),
              ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, childIndex) => Container(
                      height: 75,
                      padding: const EdgeInsets.all(8),
                      color: results[parentIndex].value[childIndex].isSelected
                          ? side2ndBackgroundSelect
                          : side2ndBackground,
                      child: RichText(
                        text: TextSpan(
                          text:
                              results[parentIndex].value[childIndex].plainText,
                          style: const TextStyle(
                              color: textColor, fontFamily: "RictyDiminished"),
                        ),
                      )),
                  separatorBuilder: (context, childIndex) =>
                      const Divider(color: dividerColor, height: 0.5),
                  itemCount: results[parentIndex].value.length)
            ]),
        itemCount: results.length);
  }
}
