import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: Text('ErrorPage'),
        ),
      ),
    );
  }
}