import 'package:flutter/material.dart';

class OwnerScreen extends StatelessWidget {
  static const routeName = '/owner-screen';

  const OwnerScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Home'),
      ),
      body: Center(
        child: Text('Hey Owner, welcome!'),
      ),
    );
  }
}
