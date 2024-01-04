import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/city.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../widgets/owner/manage_city_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import 'owner_city_screen.dart';

class OwnerScreen extends StatelessWidget {
  static const String _TAG = 'OwnerScreen';

  const OwnerScreen({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(
          title: 'owner',
        ),
        titleSpacing: 0,
      ),
      // drawer: AppDrawer(),
      body: _buildCities(context),
    );
  }

  _buildCities(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getCitiesSnapshot(),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              List<City> cities = [];
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final City ms = Fresh.freshCityMap(document.id, data, false);
                cities.add(ms);
              }
              return _displayCities(context, cities);
            }
        }
      },
    );
  }

  _displayCities(BuildContext context, List<City> cities) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: cities.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageCityItem(
                  city: cities[index],
                ),
                onTap: () {
                  City city = cities[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => OwnerCityScreen(city: city)),
                  );
                });
          }),
    );
  }
}
