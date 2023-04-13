import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/bloc_item.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/city.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
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
        title: Text('owner | ' + city.name),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => BlocAddEditScreen(bloc: Dummy.getDummyBloc(city.id),task: 'Add',)),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'new bloc',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          buildBlocs(context),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  buildBlocs(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(5),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getBlocsByCityId(city.id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
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
              final Bloc bloc = Fresh.freshBlocMap(data, false);

              return BlocItem(bloc, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
