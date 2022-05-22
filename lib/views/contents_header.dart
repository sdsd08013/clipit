import 'package:flutter/material.dart';
import '../color.dart';

class ContentsHeader extends StatelessWidget {
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleMoveToPinTap;
  final VoidCallback handleMoveToTrashTap;

  const ContentsHeader(
      {Key? key,
      required this.handleCopyToClipboardTap,
      required this.handleMoveToPinTap,
      required this.handleMoveToTrashTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: headerBackground,
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
              ))
        ]));
  }
}
