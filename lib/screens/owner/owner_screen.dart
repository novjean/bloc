import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/city_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../db/entity/city.dart';

class OwnerScreen extends StatelessWidget {
  static const routeName = '/owner-screen';
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    logger.i('owner screen is loading...');

    final dao = ModalRoute.of(context)!.settings.arguments as BlocDao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context, dao),
    );
  }

  _buildBody(BuildContext context, BlocDao dao) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildCities(context, dao),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  buildCities(BuildContext context, BlocDao dao) {
    final Stream<QuerySnapshot> _citiesStream = FirestoreHelper.getCitiesSnapshot();

    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(5),
      child: StreamBuilder<QuerySnapshot>(
        stream: _citiesStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text("Something went wrong");
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
              BlocRepository.insertCity(dao, city);

              return CityItem(city, dao, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
