import 'package:bloc/screens/new_bloc_screen.dart';
import 'package:flutter/material.dart';

class CityDetailScreen extends StatelessWidget {
  static const routeName = '/city-detail';

  // final String tag;
  // final String cityName;

  @override
  Widget build(BuildContext context) {
    final cityName = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            NewBlocScreen.routeName,
            arguments: cityName,
          );
        },
        child: Icon(Icons.add, color: Colors.black, size: 29,),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Bloc',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Text('List of Bloc outlets loading...'),
      ),
    );
  }
}
