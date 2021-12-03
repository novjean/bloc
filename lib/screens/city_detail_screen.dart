import 'package:flutter/material.dart';

class CityDetailScreen extends StatelessWidget {
  static const routeName = '/city-detail';

  // final String tag;
  // final String cityName;

  // const CityDetailScreen({Key key}) : super(key: key);

  // const CityDetailScreen({this.tag, this.cityName});

  @override
  Widget build(BuildContext context) {
    final cityName = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.black, size: 29,),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Bloc',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Text('We are here!'),
      ),
    );
  }
}
