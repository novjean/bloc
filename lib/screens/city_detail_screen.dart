import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/screens/forms/new_bloc_screen.dart';
import 'package:bloc/widgets/bloc_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc.dart';
import '../db/entity/city.dart';
import '../utils/bloc_utils.dart';

class CityDetailScreen extends StatelessWidget {
  static const routeName = '/city-detail';
  BlocDao dao;
  City city;

  CityDetailScreen({key, required this.dao, required this.city})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(city.name),
      ),
      // drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => NewBlocScreen(city: city)),
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
      body: _buildBody(context,dao),
    );
  }

  _buildBody(BuildContext context, BlocDao dao) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildBlocs(context, dao),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  buildBlocs(BuildContext context, BlocDao dao) {
    final Stream<QuerySnapshot> _blocsStream = FirebaseFirestore.instance
        .collection('blocs')
        .where('city', isEqualTo: city.id)
        .snapshots();

    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(5),
      child: StreamBuilder<QuerySnapshot>(
        stream: _blocsStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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

              final Bloc bloc = BlocUtils.getBloc(data, document.id);
              BlocRepository.insertBloc(dao, bloc);

              return BlocItem(bloc, dao, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
