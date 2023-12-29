import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/city_item.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/city.dart';
import '../../widgets/ui/app_bar_title.dart';

class OwnerScreen extends StatelessWidget {
  static const String _TAG = 'OwnerScreen';

  const OwnerScreen({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'owner',),
        titleSpacing: 0,
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildCities(context),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  buildCities(BuildContext context) {
    final Stream<QuerySnapshot> _citiesStream = FirestoreHelper.getCitiesSnapshot();

    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(5),
      child: StreamBuilder<QuerySnapshot>(
        stream: _citiesStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return Center(child: Text("something went wrong"));
          }

          return GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              String imageUrl = data['imageUrl'];
              String name = data['name'];
              String ownerId = data['owner_id'];
              String cityId = document.id;
              final City city = City(cityId, name, ownerId, imageUrl);
              // BlocRepository.insertCity(dao, city);
              //
              return CityItem(city, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
