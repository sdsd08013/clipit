import 'package:clipit/models/side_type.dart';
import 'package:clipit/providers/top_state_provider.dart';
import 'package:clipit/views/side_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../color.dart';
import '../icon_text.dart';
import '../providers/offset_provider.dart';
import '../states/top_state.dart';
import 'contents_list_view.dart';

class MainSideBarView extends ConsumerWidget {
  double dragStartPos = 0;
  ScreenType2VoidFunc handleSideBarTap;
  MainSideBarView({Key? key, required this.handleSideBarTap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appWidth = MediaQuery.of(context).size.width;
    const ratio1 = 0.15;
    const ratio2 = 0.85;
    const ratio3 = 0.3;
    const ratio4 = 0.7;
    double offset = ref.watch(offsetProvider);
    TopState topState = ref.watch(topStateProvider);
    return Container(
        color: side1stBackground,
        width: appWidth * ratio1 - 2 - offset,
        child: Stack(children: [
          SideMenu(
              key: GlobalKey(),
              type: topState.type,
              handleSideBarTap: handleSideBarTap),
          Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  color: topState.type == ScreenType.SETTING
                      ? side1stBackgroundSelect
                      : side1stBackground,
                  child: IconText(
                    icon: Icons.settings,
                    text: "setting",
                    textColor: textColor,
                    iconColor: iconColor,
                    onTap: () => handleSideBarTap(ScreenType.SETTING),
                  ))),
        ]));
  }
}
