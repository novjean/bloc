import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/seat.dart';
import '../../db/entity/service_table.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/seat_item.dart';

class SeatsManagementScreen extends StatefulWidget {
  String serviceId;
  BlocDao dao;
  ServiceTable serviceTable;

  SeatsManagementScreen(
      {required this.serviceId, required this.dao, required this.serviceTable});

  @override
  State<SeatsManagementScreen> createState() => _SeatsManagementScreenState();
}

class _SeatsManagementScreenState extends State<SeatsManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Table Number : ' + widget.serviceTable.tableNumber.toString())),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // scanQR();
      //   },
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.black,
      //     size: 29,
      //   ),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   tooltip: 'New Seat',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, widget.serviceTable),
    );
  }

  _buildBody(BuildContext context, ServiceTable serviceTable) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          _pullSeats(context),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _pullSeats(BuildContext context) {
    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.getSeats(widget.serviceId, widget.serviceTable.tableNumber);
    return StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Seat> seats = [];
          if (snapshot.data!.docs.length > 0) {
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final Seat seat = Seat.fromJson(data);
              BlocRepository.insertSeat(widget.dao, seat);
              seats.add(seat);

              if (i == snapshot.data!.docs.length - 1) {
                return _displaySeats(context, seats);
              }
            }
          } else {
            // seats are not defined in floor, adding them
            for(int i=0;i<widget.serviceTable.capacity; i++){
              Seat seat = Seat(
                  custId: "",
                  id: StringUtils.getRandomString(20),
                  serviceId: widget.serviceId,
                  tableNumber: widget.serviceTable.tableNumber);
              seats.add(seat);
              BlocRepository.insertSeat(widget.dao, seat);
              FirestoreHelper.uploadSeat(seat);
            }
            return _displaySeats(context, seats);
          }

          return Text('Pulling seats...');
        });
  }

  _loadSeats(BuildContext context) {
    Future<List<Seat>> fSeats = BlocRepository.getSeats(widget.dao, widget.serviceId, widget.serviceTable.tableNumber);

    return FutureBuilder(
      future: fSeats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading seats...');
        } else {
          List<Seat> seats = snapshot.data! as List<Seat>;
          if(seats.isEmpty){
            return _pullSeats(context);
          }
          return _displaySeats(context, seats);
        }
      },
    );
  }

  _displaySeats(BuildContext context, List<Seat> seats) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: seats.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SeatItem(
                  seat: seats[index],
                ),
                onTap: () {
                  Seat seat = seats[index];

                  if(!seat.custId.isEmpty){
                    logger.i('seat is occupied.');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("AlertDialog"),
                          content: Text("Would you like to make the seat available?"),
                          actions: [
                            TextButton(
                              child: Text("Yes"),
                              onPressed:  () {
                                FirestoreHelper.updateSeat(seat.id, '');
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("No"),
                              onPressed:  () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      },
                    );
                  } else {
                    scanQR(seat);
                  }
                  logger.d(
                      'seat selected : ' + seat.id);
                });
          }),
    );
  }

  Future<void> scanQR(Seat seat) async {
    String scanCustId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scanCustId = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(scanCustId);
    } on PlatformException {
      scanCustId = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if(scanCustId.compareTo('-1')==0){
      return;
    }
    // update seat in floor
    BlocRepository.updateCustInSeat(widget.dao, seat.id, scanCustId);
    BlocRepository.updateTableOccupyStatus(widget.dao, seat.serviceId, seat.tableNumber, true);

    seat.custId = scanCustId;
    FirestoreHelper.updateSeat(seat.id, scanCustId);
    FirestoreHelper.updateServiceTable(widget.serviceTable.id, true);

    setState(() {
      widget.serviceTable.isOccupied = true;
    });
  }
}