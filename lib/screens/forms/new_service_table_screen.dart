import 'package:bloc/db/entity/service_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../helpers/firestore_helper.dart';
import '../../utils/string_utils.dart';
import '../../widgets/table/new_service_table_form.dart';
import '../../widgets/ui/Toaster.dart';

class NewServiceTableScreen extends StatefulWidget {
  String serviceId;

  NewServiceTableScreen({key, required this.serviceId}) : super(key: key);

  @override
  _NewServiceTableScreenState createState() => _NewServiceTableScreenState();
}

class _NewServiceTableScreenState extends State<NewServiceTableScreen> {
  var logger = Logger();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Table'),
      ),
      // drawer: AppDrawer(),
      body: NewServiceTableForm(_submitTableForm, _isLoading),
    );
  }

  void _submitTableForm(
    int tableNumber,
    int capacity,
    String captainId,
    bool isActive,
    BuildContext ctx,
  ) async {
    logger.i('_submitTableForm called');

    setState(() {
      _isLoading = true;
    });

    String tableId = StringUtils.getRandomString(20);
    ServiceTable table = ServiceTable(
        id: tableId,
        serviceId: widget.serviceId,
        captainId: captainId,
        tableNumber: tableNumber,
        capacity: capacity,
        isOccupied: false,
        isActive: isActive,
        type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID
    );

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreHelper.TABLES)
          .doc(table.id)
          .set(table.toMap());

      Toaster.shortToast(table.tableNumber.toString() + " is added.");

      Navigator.of(context).pop();
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';
      logger.e(err.message);
      Toaster.shortToast("Error : " + message);

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      logger.e(err);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
