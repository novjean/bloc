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
    final Stream<QuerySnapshot> _citiesStream = FirebaseFirestore.instance.collection('cities').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
      ),
      drawer: AppDrawer(),
      body:

      StreamBuilder<QuerySnapshot>(
        stream: _citiesStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // final document = snapshot.data!.docs.map as DocumentSnapshot;
          // Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return CityItem(
                document.id,
                data['name'],
                data['imageUrl'],
                key: ValueKey(document.id),
              );
              // return ListTile(
              //   title: Text(data['name']),
              //   subtitle: Text(data['imageUrl']),
              // );
            }).toList(),
          );

          // return GridView(
          //   // const keyword can be used so that it does not rebuild when the build method is called
          //   // useful for performance improvement
          //   padding: const EdgeInsets.all(10.0),
          //   itemCount: data.length,
          //   // grid delegate describes how many grids should be there
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 1,
          //     childAspectRatio: 3 / 2,
          //     crossAxisSpacing: 10,
          //     mainAxisSpacing: 10,
          //   ),
          //   // item builder defines how the grid should look
          //   itemBuilder: (ctx, index) =>
          //       // Text(cityDocs[index].id),
          //   CityItem(
          //     document[index].id,
          //     data['name'],
          //     data['imageUrl'],
          //     key: ValueKey(document[index].id),
          //   ),
          // );
        },
      ),
    );
  }
}
