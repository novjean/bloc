import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/bloc_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/city.dart';
import '../../helpers/dummy.dart';
import 'bloc_add_edit_screen.dart';

class OwnerCityScreen extends StatelessWidget {
  static const routeName = '/city-detail';
  City city;

  OwnerCityScreen({key, required this.city})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner | ' + city.name),
      ),
      // drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => BlocAddEditScreen(bloc: Dummy.getDummyBloc(city.id),task: 'Add',)),
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
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildBlocs(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  buildBlocs(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(5),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getBlocsByCityId(city.id),
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

              final Bloc bloc = Bloc.fromMap(data);
              // BlocRepository.insertBloc(dao, bloc);

              return BlocItem(bloc, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
