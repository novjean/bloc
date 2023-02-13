import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/screens/manager/tables/table_add_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/service_table.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/service_table_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class CaptainTablesScreen extends StatefulWidget {
  String blocServiceId;
  String serviceName;
  String userTitle;

  CaptainTablesScreen(
      {required this.blocServiceId,
      required this.serviceName,
      required this.userTitle});

  @override
  State<CaptainTablesScreen> createState() => _CaptainTablesScreenState();
}

class _CaptainTablesScreenState extends State<CaptainTablesScreen> {
  // String _selectedType = 'private';

  List<ServiceTable> tables = [];
  bool isTablesLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullTablesByCaptainId(
            widget.blocServiceId, UserPreferences.myUser.id)
        .then((res) {
      print('successfully pulled in captain tables');

      List<ServiceTable> _tables = [];
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final ServiceTable table = ServiceTable.fromMap(data);
          _tables.add(table);
        }

        setState(() {
          tables = _tables;
          isTablesLoading = false;
        });
      } else {
        print('tables could not be found for captain id ' +
            UserPreferences.myUser.id);
        setState(() {
          isTablesLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('captain | tables')),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 2.0),
        // _displayOptions(context),
        // const Divider(),
        SizedBox(height: 2.0),
        _displayServiceTables(context),
        SizedBox(height: 2.0),
      ],
    );
  }

  // _displayOptions(BuildContext context) {
  //   List<String> _options = ['private', 'community'];
  //   double containerHeight = MediaQuery.of(context).size.height / 20;
  //
  //   return SizedBox(
  //     key: UniqueKey(),
  //     // this height has to match with category item container height
  //     height: containerHeight,
  //     child: ListView.builder(
  //         itemCount: _options.length,
  //         scrollDirection: Axis.horizontal,
  //         itemBuilder: (ctx, index) {
  //           return GestureDetector(
  //               child: SizedListViewBlock(
  //                 title: _options[index],
  //                 height: containerHeight,
  //                 width: MediaQuery.of(context).size.width / 2,
  //               ),
  //               onTap: () {
  //                 setState(() {
  //                   _selectedType = _options[index];
  //                   print(_selectedType + ' tables display option is selected');
  //                 });
  //               });
  //         }),
  //   );
  // }

  // _buildTables(BuildContext context) {
  //   final user = UserPreferences.getUser();
  //   final Stream<QuerySnapshot<Object?>> stream;
  //   if (user.clearanceLevel >= Constants.CAPTAIN_LEVEL &&
  //       user.clearanceLevel < Constants.MANAGER_LEVEL) {
  //     stream = FirestoreHelper.getTablesByTypeAndUser(
  //         widget.blocServiceId, user.id, _selectedType);
  //   } else {
  //     stream =
  //         FirestoreHelper.getTablesByType(widget.blocServiceId, _selectedType);
  //   }
  //
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: stream,
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
  //               document.data()! as Map<String, dynamic>;
  //           final ServiceTable serviceTable = ServiceTable.fromMap(data);
  //           serviceTables.add(serviceTable);
  //         }
  //         return _displayServiceTables(context, t);
  //       });
  // }

  _displayServiceTables(BuildContext context) {
    if (tables.isEmpty) {
      return Center(child: Text('pulling tables...'));
    } else {
      return Expanded(
        child: ListView.builder(
            itemCount: tables.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (ctx, index) {
              return GestureDetector(
                  child: ServiceTableItem(
                    serviceTable: tables[index],
                  ),
                  // chick my frever love
                  // onDoubleTap: () {
                  //   if (UserPreferences.myUser.clearanceLevel >=
                  //       Constants.MANAGER_LEVEL) {
                  //     logger.d('double tap selected : ' + index.toString());
                  //     FirestoreHelper.changeTableColor(serviceTables[index]);
                  //   }
                  // },
                  onTap: () {
                    logger.d('tap selected : ' + index.toString());
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TableAddEditScreen(
                          table: tables[index], task: 'edit'),
                    ));
                  });
            }),
      );
    }
  }
}
