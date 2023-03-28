import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/screens/manager/tables/table_add_edit_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/service_table.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/service_table_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class ManageTablesScreen extends StatefulWidget {
  String blocServiceId;
  String serviceName;
  String userTitle;

  ManageTablesScreen(
      {required this.blocServiceId,
      required this.serviceName,
      required this.userTitle});

  @override
  State<ManageTablesScreen> createState() => _ManageTablesScreenState();
}

class _ManageTablesScreenState extends State<ManageTablesScreen> {
  static const String _TAG = 'ManageTablesScreen';

  String _selectedType = 'private';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('manage | tables')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) =>
                    TableAddEditScreen(table: Dummy.getDummyTable(widget.blocServiceId), task: 'add'),
                    // NewServiceTableScreen(serviceId: widget.blocServiceId)
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'new table',
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
    List<String> _options = ['private', 'community'];
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
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    _selectedType = _options[index];
                    print(_selectedType + ' tables display option is selected');
                  });
                });
          }),
    );
  }

  _buildTables(BuildContext context) {
    final user = UserPreferences.getUser();
    final Stream<QuerySnapshot<Object?>> stream;
    if (user.clearanceLevel >= Constants.CAPTAIN_LEVEL &&
        user.clearanceLevel < Constants.MANAGER_LEVEL) {
      stream = FirestoreHelper.getTablesByTypeAndUser(
          widget.blocServiceId, user.id, _selectedType);
    } else {
      stream =
          FirestoreHelper.getTablesByType(widget.blocServiceId, _selectedType);
    }

    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget();
          }

          List<ServiceTable> serviceTables = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final ServiceTable serviceTable = ServiceTable.fromMap(data);
            serviceTables.add(serviceTable);
          }
          return _displayServiceTables(context, serviceTables);
        });
  }

  _displayServiceTables(
      BuildContext context, List<ServiceTable> serviceTables) {
    if (serviceTables.isEmpty) {
      return Text('pulling tables...');
    } else {
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
                    if (UserPreferences.myUser.clearanceLevel >=
                        Constants.MANAGER_LEVEL) {
                      Logx.i(_TAG, 'double tap selected : ' + index.toString());
                      FirestoreHelper.changeTableColor(serviceTables[index]);
                    }
                  },
                  onTap: () {
                    Logx.i(_TAG, 'tap selected : ' + index.toString());
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TableAddEditScreen(
                          table: serviceTables[index], task: 'edit'),
                    )

                        // ManageSeatsScreen(
                        // serviceId: widget.blocServiceId,
                        // serviceTable: serviceTables[index])),
                        );
                    // showOptionsDialog(context, serviceTables[index]);
                  });
            }),
      );
    }
  }
}
