import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import 'button_widget.dart';

class TableCardItem extends StatefulWidget {
  String seatId;
  int tableNumber;

  TableCardItem(this.seatId, this.tableNumber);

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
              widget.tableNumber ==-1 ? 'Table : Unassigned' : 'Table : ' + widget.tableNumber.toString(),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            // spacer is a special widget which takes up all the space it can
            Spacer(),
            widget.tableNumber == -1 ?
            ButtonWidget(
              text: 'Scan Table',
              onClicked: () {
                Toaster.shortToast('scan clicked');

                User user = UserPreferences.getUser();
                scanTableQR(user);
                },
            ) :
            ButtonWidget(
              text: 'Color',
              onClicked: () {
                Toaster.shortToast('button clicked');

                // UserPreferences.setUser(user);
                //
                // if(isPhotoChanged){
                //   FirestorageHelper.deleteFile(oldImageUrl);
                // }
                //
                // BlocRepository.updateUser(widget.dao, user);
                // FirestoreHelper.updateUser(user);

                // Navigator.of(context).pop();
              },
            ),
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
      scanTableId = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if(scanTableId.compareTo('-1')==0){
      return;
    }

    if(user.userId.isEmpty){
      Toaster.shortToast('not signed in yet.');
    } else {
      Toaster.shortToast('signed in, time to find seats for the table.');
    }

    // update seat in floor
    // BlocRepository.updateCustInSeat(widget.dao, seat.id, scanCustId);
    // BlocRepository.updateTableOccupyStatus(widget.dao, seat.serviceId, seat.tableNumber, true);
    //
    // seat.custId = scanCustId;
    // FirestoreHelper.updateSeat(seat.id, scanCustId);
    // FirestoreHelper.updateServiceTable(widget.serviceTable.id, true);
    //
    // setState(() {
    //   widget.serviceTable.isOccupied = true;
    // });
  }
}