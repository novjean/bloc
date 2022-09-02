import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/manager/tables/seats_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/service_table.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/service_table_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import '../../forms/new_service_table_screen.dart';

class TablesManagementScreen extends StatefulWidget {
  BlocDao dao;
  String blocServiceId;
  String serviceName;
  String userTitle;

  TablesManagementScreen(
      {required this.blocServiceId,
      required this.dao,
      required this.serviceName,
      required this.userTitle});

  @override
  State<TablesManagementScreen> createState() => _TablesManagementScreenState();
}

class _TablesManagementScreenState extends State<TablesManagementScreen> {
  String _selectedType = 'Community';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userTitle + ' | ' + widget.serviceName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) =>
                    NewServiceTableScreen(serviceId: widget.blocServiceId)),
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
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2.0),
        _displayOptions(context),
        const Divider(),
        SizedBox(height: 2.0),
        _buildTables(context),
        SizedBox(height: 2.0),
      ],
    );
  }

  _displayOptions(BuildContext context) {
    List<String> _options = ['Community', 'Private'];
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: containerHeight,
      child: ListView.builder(
          itemCount: _options.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: _options[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                onTap: () {
                  setState(() {
                    // _sCategory = categories[index];
                    _selectedType = _options[index];
                    print(_selectedType + ' tables display option is selected.');
                  });
                });
          }),
    );
  }

  _buildTables(BuildContext context) {
    final user = UserPreferences.getUser();
    final Stream<QuerySnapshot<Object?>> stream;
    if(user.clearanceLevel>=Constants.CAPTAIN_LEVEL && user.clearanceLevel<Constants.MANAGER_LEVEL){
      stream = FirestoreHelper.getTablesByTypeAndUser(widget.blocServiceId, user.id, _selectedType);
    } else {
      stream = FirestoreHelper.getTablesByType(widget.blocServiceId, _selectedType);
    }

    return StreamBuilder<QuerySnapshot>(
        stream: stream,
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
            final ServiceTable serviceTable = ServiceTable.fromMap(data);
            BlocRepository.insertServiceTable(widget.dao, serviceTable);
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
    return Expanded(
      child: ListView.builder(
          itemCount: serviceTables.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ServiceTableItem(
                  serviceTable: serviceTables[index],
                ),
                // chick my frever love
                onDoubleTap: () {
                  logger.d('double tap selected : ' + index.toString());
                  FirestoreHelper.changeTableColor(serviceTables[index]);
                },
                onTap: () {
                  logger.d('tap selected : ' + index.toString());
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => SeatsManagementScreen(
                            serviceId: widget.blocServiceId,
                            dao: widget.dao,
                            serviceTable: serviceTables[index])),
                  );
                  // showOptionsDialog(context, serviceTables[index]);
                });
          }),
    );
  }

  // showOptionsDialog(BuildContext context, ServiceTable _table) {
  //   // set up the AlertDialog for Table options
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Table Options"),
  //     content: Text("Please select what action would you like to perform."),
  //     actions: [
  //       TextButton(
  //         child: Text("Cancel"),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //       TextButton(
  //         child: Text("Change Color"),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //
  //           FirestoreHelper.changeTableColor(_table);
  //         },
  //       ),
  //       TextButton(
  //         child: Text("Manage Seats"),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //
  //           Navigator.of(context).push(
  //             MaterialPageRoute(
  //                 builder: (context) => SeatsManagementScreen(
  //                     serviceId: widget.blocServiceId,
  //                     dao: widget.dao,
  //                     serviceTable: _table)),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }
}
