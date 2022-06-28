class Directable {
  final String name;
  bool isSelected;
  Directable({required this.name, required this.isSelected});
}

class TreeBranch implements Directable {
  @override
  bool isSelected;

  @override
  final String name;
  TreeBranch({required this.name, required this.isSelected});
}
