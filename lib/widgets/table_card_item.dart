import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../db/entity/seat.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../utils/logx.dart';

class TableCardItem extends StatefulWidget {
  String seatId;
  int tableNumber;
  String tableId;
  bool isCommunity;

  TableCardItem(
      {required this.seatId,
      required this.tableNumber,
      required this.tableId,
      required this.isCommunity});

  @override
  State<TableCardItem> createState() => _TableCardItemState();
}

class _TableCardItemState extends State<TableCardItem> {
  static const String _TAG = 'TableCardItem';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.tableNumber == -1
                  ? 'table : unassigned'
                  : 'table : ' + widget.tableNumber.toString(),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            // spacer is a special widget which takes up all the space it can
            Spacer(),
            widget.tableNumber == -1
                ? ButtonWidget(
                    text: 'scan table',
                    onClicked: () {
                      Toaster.shortToast('scanning for table QR code...');

                      User user = UserPreferences.getUser();
                      scanTableQR(user);
                    },
                  )
                : _displayTableType(),
          ],
        ),
      ),
    );
  }

  Future<void> scanTableQR(User user) async {
    String scanTableId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scanTableId = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(scanTableId);
    } on PlatformException {
      scanTableId = 'failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (scanTableId.compareTo('-1') == 0) {
      Logx.i(_TAG, 'scan cancelled');
      return;
    }

    if (!user.id.isEmpty) {
      // set the table as occupied
      FirestoreHelper.setTableOccupyStatus(scanTableId, true);

      // find the seats associated with this table
      FirebaseFirestore.instance
          .collection(FirestoreHelper.SEATS)
          .where('tableId', isEqualTo: scanTableId)
          .get()
          .then(
        (result) {
          bool isSeatAvailable = false;
          if (result.docs.isNotEmpty) {
            for (int i = 0; i < result.docs.length; i++) {
              DocumentSnapshot document = result.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final Seat seat = Seat.fromMap(data);

              if (seat.custId.isEmpty) {
                FirestoreHelper.updateSeat(seat.id, user.id);
                // here we update the user's bloc service id
                FirestoreHelper.updateUserBlocId(user.id, seat.serviceId);
                break;
              }

              if (i == result.docs.length - 1) {
                if (!isSeatAvailable) {
                  print(widget.tableNumber.toString() +
                      ' does not have a seat for ' +
                      user.name);
                }
                Toaster.shortToast('Sorry, no seats left on the table!');
              }
            }
          } else {
            print('seats could not be found for ' + scanTableId);
          }
        },
        onError: (e) => print("error: $e"),
      );
    } else {
      Toaster.shortToast('not signed in, write go to log in logic here!');
    }
  }

  _displayTableType() {
    String tableType = widget.isCommunity ? 'community' : 'private';
    return ButtonWidget(
      text: tableType,
      onClicked: () {
        Toaster.shortToast('you are sitting in a ' + tableType + ' table');
      },
    );
  }
}
