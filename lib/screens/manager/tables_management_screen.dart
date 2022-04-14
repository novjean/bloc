import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/manager_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/service_table.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/service_table_item.dart';
import '../forms/new_service_table_screen.dart';

class TablesManagementScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;
  ManagerService managerService;

  TablesManagementScreen(
      {required this.serviceId,
      required this.dao,
      required this.managerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(managerService.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => NewServiceTableScreen(serviceId: serviceId)),
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
      body: _buildBody(context, managerService),
    );
  }

  _buildBody(BuildContext context, ManagerService managerService) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          _buildTables(context),
          SizedBox(height: 5.0),
          // buildProducts(context),
          // SizedBox(height: 50.0),
        ],
      ),
    );
  }

  _buildTables(BuildContext context) {
    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.getTablesSnapshot(serviceId);
    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<ServiceTable> serviceTables = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final ServiceTable serviceTable = ServiceTable.fromJson(data);
            BlocRepository.insertServiceTable(dao, serviceTable);
            serviceTables.add(serviceTable);

            // return Text('table : ' + table.tableNumber.toString());

            if (i == snapshot.data!.docs.length - 1) {
              return _displayServiceTables(context, serviceTables);
            }
          }
          return Text('Loading cart items...');
        });
  }

  _displayServiceTables(
      BuildContext context, List<ServiceTable> serviceTables) {

    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: serviceTables.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {

            return GestureDetector(
                child: ServiceTableItem(
                  serviceTable: serviceTables[index],
                ),
                onTap: () {
                  {
                    logger.d('manager service index selected : ' +
                        index.toString());
                  }
                });
          }),
    );
  }
}
