import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../icon_text.dart';
import '../models/side_type.dart';
import '../models/tree_node.dart';
import '../providers/top_state_provider.dart';
import '../types.dart';

class SideMenu extends ConsumerWidget {
  final ScreenType type;
  final ScreenType2VoidFunc handleSideBarTap;
  const SideMenu({Key? key, required this.type, required this.handleSideBarTap})
      : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TreeNode> children = ref.watch(topStateProvider).root.children ?? [];
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
