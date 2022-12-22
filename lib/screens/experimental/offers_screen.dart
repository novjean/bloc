import 'package:flutter/material.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context){
    return Column(
      children: [
        Center(child:Text('Work in progress!')),
      ],
    );
  }
}
