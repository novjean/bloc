import 'package:bloc/db/entity/service_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../helpers/firestore_helper.dart';
import '../../utils/string_utils.dart';
import '../../widgets/table/new_service_table_form.dart';

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
        type: FirestoreHelper.TABLE_PRIVATE_TYPE_ID
    );

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreHelper.TABLES)
          .doc(table.id)
          .set(table.toMap());

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(table.tableNumber.toString() + " is added!"),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      Navigator.of(context).pop();
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';
      logger.e(err.message);
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
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
