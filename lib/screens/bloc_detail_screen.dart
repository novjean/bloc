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
          buildBanner(context),
          SizedBox(height: 20.0),
          buildBlocs(context),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  buildBanner(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      elevation: 3.0,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 5.5,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/images/product-placeholder.png'),
                    image: bloc.imageUrl != "url"
                        ? NetworkImage(bloc.imageUrl)
                        : NetworkImage("assets/images/product-placeholder.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
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

              return BlocServiceItem(service, dao, key: ValueKey(document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
