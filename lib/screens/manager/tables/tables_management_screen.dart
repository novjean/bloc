import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/manager_service.dart';
import 'package:bloc/screens/manager/tables/seats_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/service_table.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/service_table_item.dart';
import '../../forms/new_service_table_screen.dart';

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
        tooltip: 'New Table',
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

            if (i == snapshot.data!.docs.length - 1) {
              return _displayServiceTables(context, serviceTables);
            }
          }
          return Text('Pulling tables...');
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
                onDoubleTap: () {
                  logger.d('double tap selected : ' + index.toString());
                  FirestoreHelper.changeTableColor(serviceTables[index]);
                },
                onTap: () {
                  logger.d('tap selected : ' + index.toString());
                  showOptionsDialog(context, serviceTables[index]);
                });
          }),
    );
  }

  showOptionsDialog(BuildContext context, ServiceTable _table) {
    // set up the AlertDialog for Table options
    AlertDialog alert = AlertDialog(
      title: Text("Table Options"),
      content: Text("Please select what action would you like to perform."),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed:  () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Change Color"),
          onPressed:  () {
            Navigator.of(context).pop();

            FirestoreHelper.changeTableColor(_table);
          },
        ),
        TextButton(
          child: Text("Manage Seats"),
          onPressed:  () {
            Navigator.of(context).pop();

            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => SeatsManagementScreen(
                      serviceId: serviceId,
                      dao: dao,
                      serviceTable: _table)),
            );
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


}
