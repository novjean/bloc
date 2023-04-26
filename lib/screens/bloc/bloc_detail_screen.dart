import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/owner/bloc_service_add_edit_screen.dart';
import 'package:bloc/widgets/ui/cover_photo.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/bloc_service.dart';
import '../../helpers/dummy.dart';
import '../../widgets/bloc_service_item.dart';

class BlocDetailScreen extends StatelessWidget {
  static const routeName = '/bloc-detail';
  Bloc bloc;

  BlocDetailScreen({key, required this.bloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bloc.name),
      ),
      // drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => BlocServiceAddEditScreen(
                      blocService: Dummy.getDummyBlocService(bloc.id),
                      task: 'add',
                    )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'new bloc service',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        children: [
          CoverPhoto(bloc.name, bloc.imageUrls.first),
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
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getBlocServices(bloc.id),
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

              final BlocService service = BlocService.fromMap(data);

              return BlocServiceItem(service, false,
                  key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
