import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../utils/bloc_service_utils.dart';
import '../widgets/bloc_service_item.dart';

class ManagerScreen extends StatelessWidget {
  static const routeName = '/manager-screen';
  BlocDao dao;

  ManagerScreen({key, required this.dao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.i('manager screen is loading...');

    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Home'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          buildBlocServices(context),
          SizedBox(height: 5.0),
          // buildProducts(context),
          // SizedBox(height: 50.0),
        ],
      ),
    );
  }

  buildBlocServices(BuildContext context) {
    final Stream<QuerySnapshot> _servicesStream =
        FirestoreHelper.getServicesSnapshot();

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

              return BlocServiceItem(service, dao, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );

    // return StreamBuilder<QuerySnapshot>(stream: _blocsStream, builder: (ctx, snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //     return const Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   }
    //
    //   // for (int i = 0; i < snapshot.data!.docs.length; i++) {
    //   //   DocumentSnapshot document = snapshot.data!.docs[i];
    //   //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    //   //
    //   //   final BlocService service = BlocServiceUtils.getBlocService(data, document.id);
    //   //   // BlocRepository.insertCategory(widget.dao, cat);
    //   //
    //   //   // if (i == snapshot.data!.docs.length - 1) {
    //   //   //   // return displayCategoryList(context);
    //   //   //   return Text(service.name);
    //   //   // }
    //   //
    //   //
    //   // }
    //
    //   return Text('Loading services...');
    //
    // });
  }
}
