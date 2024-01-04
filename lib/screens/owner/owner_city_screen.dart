import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/city.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../widgets/owner/owner_bloc_item.dart';
import 'bloc_add_edit_screen.dart';

class OwnerCityScreen extends StatelessWidget {
  City city;

  OwnerCityScreen({key, required this.city})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: city.name.toLowerCase(), ),
        titleSpacing: 0,
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
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _buildBlocs(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildBlocs(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getBlocsByCityId(city.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
        case ConnectionState.waiting:
        case ConnectionState.none:
        return const LoadingWidget();
        case ConnectionState.active:
        case ConnectionState.done:
          List<Bloc> blocs = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;
            final Bloc bloc = Fresh.freshBlocMap(data, false);
            blocs.add(bloc);
          }

          return _displayBlocs(context, blocs);
        }
      },
    );
  }

  _displayBlocs(BuildContext context, List<Bloc> blocs) {
    return Expanded(
      child: ListView.builder(
          itemCount: blocs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: OwnerBlocItem(
                  bloc: blocs[index],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => BlocAddEditScreen(
                          bloc: blocs[index],
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }

}
