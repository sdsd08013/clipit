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
  Selectable? item;
  TreeNode? parent;
  List<TreeNode>? children;
  TreeNode? prev;
  TreeNode? next;
  TreeNode? self;
  IconData? icon;
  String mdText = "";
  String listText = "";
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

    if (item != null && item is Selectable) {
      mdText = (item as Selectable).mdText;
      listText = (item as Selectable).plainText;
    } else {
      mdText = name;
      listText = name;
    }
  }

  TreeNode copyWith(
      {String? name,
      bool? isSlected,
      Selectable? item,
      TreeNode? parent,
      TreeNode? prev,
      TreeNode? next,
      List<TreeNode>? children,
      IconData? icon}) {
    return TreeNode(
        name: name ?? this.name,
        isSelected: isSelected,
        isDir: isDir,
        item: item ?? this.item,
        children: children ?? this.children,
        parent: parent ?? this.parent,
        prev: prev ?? this.prev,
        next: next ?? this.next,
        icon: icon ?? this.icon);
  }

  TreeNode addSelectables({List<Selectable>? list}) {
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
    return copyWith(children: newChildren);
  }

  TreeNode addNodes({List<TreeNode>? list}) {
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
          item: item.item,
          self: item,
          prev: tmpPrev,
          parent: this);

      tmpPrev?.next = tmp;
      newChildren.add(tmp);
    });
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

  TreeNode addChildToHead(TreeNode item) {
    final List<TreeNode> nc = [item];
    nc.addAll(children as Iterable<TreeNode>);
    return copyWith(children: nc);
  }

  bool get isRoot => item == null;

  List<TreeNode> get sibilings {
    return parent?.children ?? [];
  }

  int get index {
    return sibilings.indexOf(this);
  }

  TreeNode moveToNext() {
    if (next == null) {
      return this;
    }

    isSelected = false;
    next?.isSelected = true;

    if (isDir) {
      return next!.moveToNext();
    } else {
      return next!;
    }
  }

  TreeNode moveToPrev() {
    if (prev == null) {
      return this;
    }

    isSelected = false;
    prev?.isSelected = true;
    if (isDir) {
      return children!.last.moveToPrev();
    } else {
      return prev!;
    }
  }

  void unSelect() {
    isSelected = false;
    TreeNode? nParent = parent;
    while (nParent != null) {
      nParent.isSelected = false;
      nParent = nParent.parent;
    }
  }

  void select() {
    isSelected = true;
    TreeNode? nParent = parent;
    while (nParent != null) {
      nParent.isSelected = true;
      nParent = nParent.parent;
    }
  }
}
