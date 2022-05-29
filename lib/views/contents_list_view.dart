import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  ContentsListView(
      {required this.width,
      required this.controller,
      required this.items,
      required this.onItemTap});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: side2ndBackground,
        width: width,
        child: ListView.separated(
          controller: controller,
          itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                onItemTap.call(index);
              },
              child: Container(
                  height: 80,
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
        ));
  }
}
