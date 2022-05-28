import 'package:flutter/material.dart';
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
              child: IconButton(
                iconSize: 20,
                onPressed: () => handleCopyToClipboardTap(),
                color: iconColor,
                icon: const Icon(
                  Icons.copy,
                ),
                tooltip: 'Copy to clipboard',
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                iconSize: 20,
                onPressed: () => handleMoveToPinTap(),
                color: iconColor,
                icon: const Icon(Icons.push_pin_sharp),
                tooltip: 'Pin the Data',
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                iconSize: 20,
                onPressed: () => handleMoveToTrashTap(),
                color: iconColor,
                icon: const Icon(Icons.delete),
                tooltip: 'move to trash',
              )),
          Visibility(
              visible: isEditable,
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    iconSize: 20,
                    onPressed: () => handleEditItemTap(),
                    color: iconColor,
                    icon: const Icon(Icons.edit),
                    tooltip: 'edit pinned item',
                  ))),
        ]));
  }
}
