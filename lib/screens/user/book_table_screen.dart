import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';

class BookTableScreen extends StatelessWidget{
  List<Bloc> blocs;

  BookTableScreen({required this.blocs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Table')),
      body: Center(child: Text('Work in Progress. Blocs count : ' + blocs.length.toString())),
    );
  }

}