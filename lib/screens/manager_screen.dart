import 'package:flutter/material.dart';

import '../db/database.dart';

class ManagerScreen extends StatelessWidget {
  static const routeName = '/manager-screen';

  const ManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Home'),
      ),
      body: Center(
        child: Text('Hey Manager, welcome!'),
      ),
    );
  }
}
