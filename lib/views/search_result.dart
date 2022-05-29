import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/selectable.dart';

class SearchResultView extends StatelessWidget {
  List<List<Selectable>> results;
  SearchResultView({required this.results});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, parentIndex) => Text("index:${parentIndex}"),
        separatorBuilder: (context, parentIndex) => ListView.separated(
            itemBuilder: (context, childIndex) =>
                Text("child->index:${childIndex}"),
            separatorBuilder: (context, childIndex) =>
                Divider(color: Colors.white),
            itemCount: results[parentIndex].length),
        itemCount: results.length);
  }
}
