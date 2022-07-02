class Directable {
  final String name;
  bool isSelected;
  bool isDir;
  Directable(
      {required this.name, required this.isSelected, required this.isDir});
}

class TreeBranch implements Directable {
  @override
  bool isSelected;
  @override
  bool isDir;

  @override
  final String name;
  TreeBranch(
      {required this.name, required this.isSelected, required this.isDir});
}
