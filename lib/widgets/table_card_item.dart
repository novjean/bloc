import 'dart:convert';

import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;


import '../db/entity/seat.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';

class TableCardItem extends StatefulWidget {
  String seatId;
  int tableNumber;
  String tableId;
  bool isCommunity;
  String? _token;

  TableCardItem(this.seatId, this.tableNumber, this.tableId, this.isCommunity, this._token);

  @override
  State<TableCardItem> createState() => _TableCardItemState();
}

class _TableCardItemState extends State<TableCardItem> {
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
                  ? 'Table : Unassigned'
                  : 'Table : ' + widget.tableNumber.toString(),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            // spacer is a special widget which takes up all the space it can
            Spacer(),
            widget.tableNumber == -1
                ? ButtonWidget(
                    text: 'Scan Table',
                    onClicked: () {
                      Toaster.shortToast('Scanning for table QR code...');

                      User user = UserPreferences.getUser();
                      scanTableQR(user);
                    },
                  )
                : _displayTableType() ,
            Spacer(),
            ButtonWidget(text: 'SOS', onClicked: () {
              Toaster.shortToast('I need help!' + widget._token!);
              sendSOSMessage();
            }),
          ],
        ),
      ),
    );
  }

  Future<void> sendSOSMessage() async {
    if (widget._token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    User user = UserPreferences.getUser();
    FirestoreHelper.sendSOSMessage(widget._token, user.name, user.phoneNumber, widget.tableNumber, widget.tableId, widget.seatId);

    // try {
    //   await http.post(
    //     Uri.parse('https://api.rnfirebase.io/messaging/send'),
    //     headers: <String, String>{
    //       'Content-Type': 'application/json; charset=UTF-8',
    //     },
    //     body: constructFCMPayload(widget._token),
    //   );
    //   print('FCM request for device sent!');
    // } catch (e) {
    //   print(e);
    // }
  }

  // Crude counter to make messages unique
  int _messageCount = 0;
  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Future<void> scanTableQR(User user) async {
    String scanTableId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scanTableId = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(scanTableId);
    } on PlatformException {
      scanTableId = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (scanTableId.compareTo('-1') == 0) {
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
              final Seat seat = Seat.fromJson(data);
              // BlocRepository.insertSeat(widget.dao, seat);

              if (seat.custId.isEmpty) {
                FirestoreHelper.updateSeat(seat.id, user.id);
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
            print ('seats could not be found for ' + scanTableId);
          }
        },
        onError: (e) => print("Error completing: $e"),
      );
    } else {
      Toaster.shortToast('not signed in, write go to log in logic here!');
    }
  }

  _displayTableType() {
    String tableType = widget.isCommunity?'Community':'Private';
    return ButtonWidget(
      text: tableType,
      onClicked: () {
        Toaster.shortToast('You are sitting in a ' + tableType + ' table');
      },
    );
  }
}
