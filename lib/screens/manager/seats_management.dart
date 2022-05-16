import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/button_widget.dart';
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
  String _scanBarcode = 'Unknown';
  int _seatsFilled = 0;
  List<Seat> mSeats = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Table Number : ' + widget.serviceTable.tableNumber.toString())),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // scanQR();
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Seat',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context, widget.serviceTable),
    );
  }

  _buildBody(BuildContext context, ServiceTable serviceTable) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Text('Scan result : $_scanBarcode\n',
          //     style: TextStyle(fontSize: 20)),
          // CoverPhoto(service.name, service.imageUrl),
          SizedBox(height: 2.0),
          // _seatsFilled == 0 ? _displayAddButton(context) :
          _pullSeats(context),
          // _loadSeats(context),
          SizedBox(height: 5.0),
          // _buildSeatsList(context),
        ],
      ),
    );
  }

  _pullSeats(BuildContext context) {
    final Stream<QuerySnapshot> _stream =
        FirestoreHelper.getSeatsSnapshotByTableNumber(widget.serviceTable.tableNumber);
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

    // update seat in floor
    BlocRepository.updateCustInSeat(widget.dao, seat.id, scanCustId);
    BlocRepository.updateTableOccupyStatus(widget.dao, seat.serviceId, seat.tableNumber, true);

    seat.custId = scanCustId;
    FirestoreHelper.updateSeat(seat.id, scanCustId);

    setState(() {
      widget.serviceTable.isOccupied = true;
      _scanBarcode = scanCustId;
    });
  }
}
