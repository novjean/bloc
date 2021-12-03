import 'package:bloc/models/city.dart';
import 'package:bloc/widgets/app_drawer.dart';
import 'package:bloc/widgets/city_item.dart';
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
        title: const Text('Owner'),
      ),
      drawer: AppDrawer(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add, color: Colors.white, size: 29,),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   tooltip: 'Add City',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          // return ListView.builder(
          //   reverse: true,
          //   itemCount: citys.length,
          //   itemBuilder: (ctx, index) => Center(
          //     child: Text(citys[index].data()['name']),
          //   ),
          //   //     MessageBubble(
          //   //
          //   //   citys[index].data()['name'],
          //   //   citys[index].data()['owner_id'],
          //   //   // this key is used for efficiency
          //   //   key: ValueKey(citys[index].id),
          //   // ),
          // );
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
