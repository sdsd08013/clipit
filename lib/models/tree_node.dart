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
  TreeNode(
      {required this.name,
      required this.isSelected,
      this.item,
      this.children,
      this.parent}) {
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
        isSelected: isSelected ?? this.isSelected,
        item: item ?? this.item,
        children: children ?? this.children,
        parent: parent ?? this.parent);
  }

  TreeNode addSelectables(SelectableList list) {
    final List<TreeNode> newChildren = [];
    for (var item in list.value) {
      newChildren.add(TreeNode(
          name: item.name,
          isSelected: item.isSelected,
          item: item,
          parent: this));
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
}
