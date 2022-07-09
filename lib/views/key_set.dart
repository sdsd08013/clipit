import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

final listViewDownKeySet = LogicalKeySet(LogicalKeyboardKey.keyJ);
final listViewUpKeySet = LogicalKeySet(LogicalKeyboardKey.keyK);
final listViewItemCopyKeySet =
    LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.meta);
final listViewDeleteKeySet = LogicalKeySet(LogicalKeyboardKey.keyD);
final searchKeySet = LogicalKeySet(LogicalKeyboardKey.slash);
final listViewUpToTopKeySet = LogicalKeySet(LogicalKeyboardKey.keyG);
final listViewDownToBottomKeySet =
    LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyG);
final listViewSelectKeySet = LogicalKeySet(LogicalKeyboardKey.enter);
