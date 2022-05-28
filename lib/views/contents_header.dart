import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import '../color.dart';

class ContentsHeader extends StatelessWidget {
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleMoveToPinTap;
  final VoidCallback handleMoveToTrashTap;
  final VoidCallback handleEditItemTap;
  final bool isEditable;

  const ContentsHeader(
      {Key? key,
      required this.isEditable,
      required this.handleCopyToClipboardTap,
      required this.handleMoveToPinTap,
      required this.handleMoveToTrashTap,
      required this.handleEditItemTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: side2ndBackground,
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: const EdgeInsets.all(4),
              child: MacosIconButton(
                onPressed: () => handleCopyToClipboardTap(),
                icon: const Icon(
                  Icons.copy,
                ),
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: MacosIconButton(
                onPressed: () => handleMoveToPinTap(),
                icon: const Icon(Icons.push_pin_sharp),
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: MacosIconButton(
                onPressed: () => handleMoveToTrashTap(),
                icon: const Icon(Icons.delete),
              )),
          Visibility(
              visible: isEditable,
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: MacosIconButton(
                    onPressed: () => handleEditItemTap(),
                    icon: const Icon(Icons.edit),
                  ))),
        ]));
  }
}
