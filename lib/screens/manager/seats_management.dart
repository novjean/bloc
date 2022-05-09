import 'package:flutter/material.dart';

import '../../db/dao/bloc_dao.dart';
import '../../db/entity/manager_service.dart';
import '../../db/entity/service_table.dart';

class SeatsManagementScreen extends StatelessWidget {
  String serviceId;
  BlocDao dao;
  ServiceTable serviceTable;

  SeatsManagementScreen(
      {required this.serviceId,
        required this.dao,
      required this.serviceTable});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Table Number : ' + serviceTable.tableNumber.toString())),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Country List'),
                  content: setupAlertDialoadContainer(),

                );
              });

          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //       builder: (ctx) => NewServiceTableScreen(serviceId: serviceId)),
          // );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Seat',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, serviceTable),
    );
  }
  Widget setupAlertDialoadContainer() {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Gujarat, India'),
          );
        },
      ),
    );
  }


  _buildBody(BuildContext context, ServiceTable serviceTable) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          // _buildSearchBox(context),
          SizedBox(height: 5.0),
          // _buildSeatsList(context),
          // buildProducts(context),
          // SizedBox(height: 50.0),
        ],
      ),
    );
  }

  _buildSeatsList(BuildContext context) {

  }



  // _buildTables(BuildContext context) {
  //   final Stream<QuerySnapshot> _stream =
  //   FirestoreHelper.getTablesSnapshot(serviceId);
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: _stream,
  //       builder: (ctx, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }
  //
  //         List<ServiceTable> serviceTables = [];
  //
  //         for (int i = 0; i < snapshot.data!.docs.length; i++) {
  //           DocumentSnapshot document = snapshot.data!.docs[i];
  //           Map<String, dynamic> data =
  //           document.data()! as Map<String, dynamic>;
  //           final ServiceTable serviceTable = ServiceTable.fromJson(data);
  //           BlocRepository.insertServiceTable(dao, serviceTable);
  //           serviceTables.add(serviceTable);
  //
  //           // return Text('table : ' + table.tableNumber.toString());
  //
  //           if (i == snapshot.data!.docs.length - 1) {
  //             return _displayServiceTables(context, serviceTables);
  //           }
  //         }
  //         return Text('Loading tables...');
  //       });
  // }
  //
  // _displayServiceTables(
  //     BuildContext context, List<ServiceTable> serviceTables) {
  //   return Container(
  //     height: MediaQuery.of(context).size.height,
  //     child: ListView.builder(
  //         itemCount: serviceTables.length,
  //         scrollDirection: Axis.vertical,
  //         itemBuilder: (ctx, index) {
  //           return GestureDetector(
  //               child: ServiceTableItem(
  //                 serviceTable: serviceTables[index],
  //               ),
  //               onTap: () {
  //                 logger.d(
  //                     'manager service index selected : ' + index.toString());
  //               });
  //         }),
  //   );
  // }
}