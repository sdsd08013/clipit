import 'package:clipit/models/directable.dart';
import 'package:clipit/models/selectable.dart';

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
  TreeNode(
      {required this.name,
      required this.isSelected,
      required this.isDir,
      this.item,
      this.children,
      this.parent,
      this.next,
      this.prev}) {
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
      List<TreeNode>? children}) {
    return TreeNode(
        name: name ?? this.name,
        isSelected: isSelected,
        isDir: isDir,
        item: item ?? this.item,
        children: children ?? this.children,
        parent: parent ?? this.parent);
  }

  TreeNode addSelectables(
      {List<Selectable>? list, bool isSelectFirst = false}) {
    List<TreeNode> newChildren = [];
    if (children != null) {
      newChildren = children!;
    }
    list?.asMap().forEach((index, item) {
      prev = newChildren.isEmpty ? null : newChildren.last;

      TreeNode tmp = TreeNode(
          name: item.name,
          isSelected: item.isSelected,
          isDir: item.isDir,
          item: item,
          prev: prev,
          parent: this);

      if (newChildren.isNotEmpty) {
        newChildren.last.next = tmp;
      }
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
    children?.add(item);
    return this;
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
