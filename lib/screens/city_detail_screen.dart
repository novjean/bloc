import 'package:bloc/screens/new_bloc_screen.dart';
import 'package:bloc/widgets/bloc_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityDetailScreen extends StatelessWidget {
  static const routeName = '/city-detail';

  @override
  Widget build(BuildContext context) {
    final cityName = ModalRoute.of(context)!.settings.arguments as String;
    final Stream<QuerySnapshot> _blocsStream =
        FirebaseFirestore.instance.collection('blocs').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      // drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            NewBlocScreen.routeName,
            arguments: cityName,
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Bloc',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder<QuerySnapshot>(
        stream: _blocsStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return BlocItem(
                document.id,
                data['addressLine1'],
                data['imageUrl'],
                key: ValueKey(document.id),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
