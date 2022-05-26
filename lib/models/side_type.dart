import 'dart:convert';

import 'package:clipit/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github-gist.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlight/themes/github.dart';

enum ScreenType { CLIP, PINNED, TRASH, SETTING }

class CustomBlockBuilder extends MarkdownElementBuilder {
// SEE: https://github.com/dart-lang/language/issues/559
  String trimLeadingWhitespace(String text) {
    var lines = LineSplitter.split(text);
    String commonWhitespacePrefix(String a, String b) {
      int i = 0;
      for (; i < a.length && i < b.length; i++) {
        int ca = a.codeUnitAt(i);
        int cb = b.codeUnitAt(i);
        if (ca != cb) break;
        if (ca != 0x20 /* spc */ && ca != 0x09 /* tab */) break;
      }
      return a.substring(0, i);
    }

    var prefix = lines.reduce(commonWhitespacePrefix);
    var prefixLength = prefix.length;
    return lines.map((s) => s.substring(prefixLength)).join("\n");
  }

  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    print("===============>${text}");
    return Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: preBackground,
          border: Border.all(color: preBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(trimLeadingWhitespace(text.text),
            style: TextStyle(color: preText)));
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: preBackground,
        border: Border.all(color: preBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: HighlightView(
        // The original code to be highlighted
        element.textContent,

        // Specify language
        // It is recommended to give it a value for performance
        language: language,
      ),
    );
  }
}
