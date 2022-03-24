import 'package:bloc/widgets/ui/cover_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc.dart';
import '../db/entity/bloc_service.dart';
import '../utils/bloc_service_utils.dart';
import '../widgets/bloc_service_item.dart';
import 'forms/new_bloc_service_screen.dart';

class BlocDetailScreen extends StatelessWidget {
  static const routeName = '/bloc-detail';
  BlocDao dao;
  Bloc bloc;

  BlocDetailScreen({key, required this.dao, required this.bloc})
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
                builder: (ctx) => NewBlocServiceScreen(bloc:bloc)),
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
      body: ListView(
        children: [
          CoverPhoto(bloc.name, bloc.imageUrl),
          SizedBox(height: 2.0),
          buildBlocs(context),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }

  buildBlocs(BuildContext context) {
    final Stream<QuerySnapshot> _servicesStream = FirebaseFirestore.instance
        .collection('services')
        .where('blocId', isEqualTo: bloc.id)
        .snapshots();
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: _servicesStream,
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

              final BlocService service = BlocServiceUtils.getBlocService(data, document.id);
              BlocRepository.insertBlocService(dao, service);

              return BlocServiceItem(service, false, dao, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
