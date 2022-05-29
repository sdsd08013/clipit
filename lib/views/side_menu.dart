import 'package:clipit/views/contents_list_view.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../icon_text.dart';
import '../models/side_type.dart';

class SideMenu extends StatelessWidget {
  final ScreenType type;
  final ScreenType2VoidFunc handleSideBarTap;
  const SideMenu({required this.type, required this.handleSideBarTap});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          width: double.infinity,
          color: type == ScreenType.CLIP
              ? side1stBackgroundSelect
              : side1stBackground,
          child: IconText(
            icon: Icons.history,
            text: "history",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () => handleSideBarTap(ScreenType.CLIP),
          )),
      Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          width: double.infinity,
          color: type == ScreenType.PINNED
              ? side1stBackgroundSelect
              : side1stBackground,
          child: IconText(
            icon: Icons.push_pin_sharp,
            text: "pinned",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () => handleSideBarTap(ScreenType.PINNED),
          )),
      Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          width: double.infinity,
          color: type == ScreenType.TRASH
              ? side1stBackgroundSelect
              : side1stBackground,
          child: IconText(
            icon: Icons.delete,
            text: "trash",
            textColor: textColor,
            iconColor: iconColor,
            onTap: () => handleSideBarTap(ScreenType.TRASH),
          )),
    ]);
  }
}
