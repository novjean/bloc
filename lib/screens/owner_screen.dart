import 'package:bloc/widgets/app_drawer.dart';
import 'package:bloc/widgets/city_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class OwnerScreen extends StatelessWidget {
  static const routeName = '/owner-screen';
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.i('owner screen is loading...');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cities').snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final cityDocs = snapshot.data.docs;

          return GridView.builder(
            // const keyword can be used so that it does not rebuild when the build method is called
            // useful for performance improvement
            padding: const EdgeInsets.all(10.0),
            itemCount: cityDocs.length,
            // grid delegate describes how many grids should be there
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            // item builder defines how the grid should look
            itemBuilder: (ctx, index) => CityItem(
              cityDocs[index].id,
              cityDocs[index].data()['name'],
              cityDocs[index].data()['imageUrl'],
              key: ValueKey(cityDocs[index].id),
            ),
          );
        },
      ),
    );
  }
}
