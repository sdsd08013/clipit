import 'package:clipit/models/directable.dart';
import 'package:clipit/models/selectable.dart';
import 'package:flutter/material.dart';

class TreeNode implements Directable {
  @override
  bool isSelected;
  @override
  bool isDir;

  @override
  final String name;
  Directable? item;
  TreeNode? parent;
  List<TreeNode>? children;
  TreeNode? prev;
  TreeNode? next;
  TreeNode? self;
  IconData? icon;
  TreeNode(
      {required this.name,
      required this.isSelected,
      required this.isDir,
      this.item,
      this.children,
      this.parent,
      this.next,
      this.prev,
      this.self,
      this.icon}) {
    if (children != null) {
      for (var child in children!) {
        child.parent = this;
      }
    }
  }

  TreeNode copyWith(
      {String? name,
      bool? isSlected,
      Directable? item,
      TreeNode? parent,
      TreeNode? prev,
      TreeNode? next,
      List<TreeNode>? children}) {
    return TreeNode(
      name: name ?? this.name,
      isSelected: isSelected,
      isDir: isDir,
      item: item ?? this.item,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      prev: prev ?? this.prev,
      next: next ?? this.next,
    );
  }

  TreeNode addSelectables(
      {List<Selectable>? list, bool isSelectFirst = false}) {
    List<TreeNode> newChildren = [];
    if (children != null) {
      newChildren = children!;
    }
    list?.asMap().forEach((index, item) {
      final tmpPrev = newChildren.isEmpty ? null : newChildren.last;

      final TreeNode tmp = TreeNode(
          name: item.subText,
          isSelected: item.isSelected,
          isDir: item.isDir,
          item: item,
          prev: tmpPrev,
          parent: this);

      tmpPrev?.next = tmp;
      newChildren.add(tmp);
    });
    if (isSelectFirst) {
      newChildren.first.isSelected = true;
    }
    return copyWith(children: newChildren);
  }

  TreeNode addNodes({List<TreeNode>? list, bool isSelectFirst = false}) {
    List<TreeNode> newChildren = [];
    if (children != null) {
      newChildren = children!;
    }
    list?.asMap().forEach((index, item) {
      final tmpPrev = newChildren.isEmpty ? null : newChildren.last;

      final TreeNode tmp = TreeNode(
          name: item.listText,
          isSelected: item.isSelected,
          isDir: item.isDir,
          item: item,
          self: item,
          prev: tmpPrev,
          parent: this);

      tmpPrev?.next = tmp;
      newChildren.add(tmp);
    });
    if (isSelectFirst) {
      newChildren.first.isSelected = true;
    }
    return copyWith(children: newChildren);
  }

  TreeNode addChildren(List<TreeNode> items) {
    final List<TreeNode> newChildren = [];
    newChildren.addAll(items);
    return copyWith(children: newChildren);
  }

  TreeNode addChild(TreeNode item) {
    final List<TreeNode>? cc = children;
    cc?.add(item);
    return copyWith(children: cc);
  }

  bool get isRoot => item == null;

  List<TreeNode> get sibilings {
    return parent?.children ?? [];
  }

  int get index {
    return sibilings.indexOf(this);
  }

  String get listText {
    return (item != null && item is Selectable)
        ? (item as Selectable).plainText
        : name;
  }
}
