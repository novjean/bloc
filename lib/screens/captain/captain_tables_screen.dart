import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/service_table.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/service_table_item.dart';
import '../../utils/logx.dart';
import '../manager/tables/manage_seats_screen.dart';

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
  static const String _TAG = 'CaptainTablesScreen';

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
      appBar: AppBar(
          title: Text('captain | tables')),
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
                  onTap: () {
                    ServiceTable table = tables[index];
                    Logx.i(_TAG,
                        'selected table : ' + table.tableNumber.toString());

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ManageSeatsScreen(
                        serviceId: widget.blocServiceId,
                        serviceTable: table,
                      ),
                    ));
                  });
            }),
      );
    }
  }
}
