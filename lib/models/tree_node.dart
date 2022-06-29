import 'package:clipit/models/directable.dart';
import 'package:clipit/models/selectable.dart';

class TreeNode implements Directable {
  @override
  bool isSelected;

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
        item: item ?? this.item,
        children: children ?? this.children,
        parent: parent ?? this.parent);
  }

  TreeNode addSelectables(SelectableList list) {
    List<TreeNode> newChildren = [];
    if (children != null) {
      newChildren = children!;
    }
    list.value.asMap().forEach((index, item) {
      prev = newChildren.isEmpty ? null : newChildren.last;

      TreeNode tmp = TreeNode(
          name: item.name,
          isSelected: item.isSelected,
          item: item,
          prev: prev,
          parent: this);

      if (newChildren.isNotEmpty) {
        newChildren.last.next = tmp;
      }
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
}
