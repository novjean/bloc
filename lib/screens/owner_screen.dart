import 'package:bloc/models/city.dart';
import 'package:bloc/widgets/app_drawer.dart';
import 'package:bloc/widgets/places_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerScreen extends StatelessWidget {
  static const routeName = '/owner-screen';

  const OwnerScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Owner'),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cities')
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final citys = snapshot.data.docs;
          return ListView.builder(
            reverse: true,
            itemCount: citys.length,
            itemBuilder: (ctx, index) => Center(
              child: Text(citys[index].data()['name']),
            ),
            //     MessageBubble(
            //
            //   citys[index].data()['name'],
            //   citys[index].data()['owner_id'],
            //   // this key is used for efficiency
            //   key: ValueKey(citys[index].id),
            // ),
          );
          // final List<City> cities = [];
          // return PlacesGrid(citys.length);
        },
      ),

      // Center(
      //   child: Text('Hey Owner, welcome!'),
      // ),
    );
  }
}
