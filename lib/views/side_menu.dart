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
    List<TreeNode> items = ref.watch(topStateProvider).firstHierarchicalDirs;
    return ListView.builder(
        itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            width: double.infinity,
            color: items[index].isSelected
                ? side1stBackgroundSelect
                : side1stBackground,
            child: IconText(
              icon: items[index].icon ?? Icons.history,
              text: items[index].name,
              textColor: textColor,
              iconColor: iconColor,
              onTap: () => handleSideBarTap(ScreenType.CLIP),
            )),
        itemCount: items.length);
  }
}
