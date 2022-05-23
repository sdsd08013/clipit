import 'package:clipit/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';

enum ScreenType { CLIP, PINNED, TRASH, SETTING }

class CustomBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: preBackground,
          border: Border.all(color: preBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text.text, style: TextStyle(color: preText)));
  }
}
