import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/logx.dart';
import '../../widgets/bloc_service_item.dart';

class ManagerMainScreen extends StatelessWidget {
  static const String _TAG = 'ManagerMainScreen';

  ManagerMainScreen({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logx.i(_TAG, 'manager screen is loading...');

    return Scaffold(
      appBar: AppBar(
        title: const Text('manager | home'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          buildBlocServices(context),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  buildBlocServices(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getAllBlocServices(),
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

              return BlocServiceItem(service, true, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
