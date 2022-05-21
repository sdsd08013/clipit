import 'package:flutter/material.dart';
import '../color.dart';

class ContentsHeader extends StatelessWidget {
  final VoidCallback handleCopyToClipboardTap;
  final VoidCallback handleArchiveClipTap;

  const ContentsHeader(
      {Key? key,
      required this.handleCopyToClipboardTap,
      required this.handleArchiveClipTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: side1stBackground,
        height: 50,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
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
                onPressed: () => handleArchiveClipTap(),
                color: iconColor,
                icon: const Icon(
                  Icons.memory,
                ),
                tooltip: 'Archive and save',
              )),
          Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                onPressed: () => handleCopyToClipboardTap(),
                color: iconColor,
                icon: const Icon(Icons.delete),
                tooltip: 'move to trash',
              ))
        ]));
  }
}
