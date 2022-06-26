import 'package:flutter/cupertino.dart';

@immutable
class SideBarWidthState {
  const SideBarWidthState({
    this.listWidth = 0,
    this.contentsWidth = 0,
  });
  final double listWidth;
  final double contentsWidth;
}
