import 'package:flutter/material.dart';

class PlacesGrid extends StatelessWidget {
  int length;

  PlacesGrid(length, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Display cities grid! : " + length.toString()),
    );
  }
}
