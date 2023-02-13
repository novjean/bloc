import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../db/bloc_repository.dart';
import '../../../db/dao/bloc_dao.dart';
import '../../../db/entity/seat.dart';
import '../../../db/entity/service_table.dart';
import '../../../db/entity/user.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/seat_item.dart';

class ManageSeatsScreen extends StatefulWidget {
  String serviceId;
  ServiceTable serviceTable;

  ManageSeatsScreen(
      {required this.serviceId, required this.serviceTable});

  @override
  State<ManageSeatsScreen> createState() => _ManageSeatsScreenState();
}

class _ManageSeatsScreenState extends State<ManageSeatsScreen> {
  late Widget captainSelectWidget;
  late String _tableCaptain = '';

  @override
  void initState() {
    captainSelectWidget = buildCaptainUsers(context);
  }

  buildCaptainUsers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUsersInRange(
            Constants.CAPTAIN_LEVEL, Constants.MANAGER_LEVEL - 1),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<User> _users = [];
          List<String> _userNames = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final User _user = User.fromMap(data);
            _users.add(_user);
            _userNames.add(_user.name);

            if(widget.serviceTable.captainId == _user.id){
              _tableCaptain = _user.name;
            }

            if (i == snapshot.data!.docs.length - 1) {
              if(_tableCaptain.isEmpty){
                _tableCaptain = 'Unassigned';
                _userNames.add(_tableCaptain);
              }

              return Card(
                margin: const EdgeInsets.all(0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('captain:', textAlign: TextAlign.start,),
                          SizedBox(height: 4.0),
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                key: const ValueKey('table_captain'),
                                decoration: InputDecoration(
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent, fontSize: 16.0),
                                    hintText: 'please select captain',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0))),
                                isEmpty: _tableCaptain == '',
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _tableCaptain,
                                    isDense: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _tableCaptain = newValue!;
                                        for(User user in _users){
                                          if(user.name.contains(newValue)){
                                            FirestoreHelper.setTableCaptain(widget.serviceTable.id, user.id);
                                          }
                                        }

                                        state.didChange(newValue);
                                      });
                                    },
                                    items: _userNames.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              // return _displayUsers(context, _users);
            }
          }
          return Text('pulling captain users...');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('manage |  seats ')),
      body: _buildBody(context, widget.serviceTable),
    );
  }

  _buildBody(BuildContext context, ServiceTable serviceTable) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('table : ' + widget.serviceTable.tableNumber.toString(), style: TextStyle(fontSize: 20),),
                  const SizedBox(height: 10),
                  Text('seats : ' + widget.serviceTable.capacity.toString(), style: TextStyle(fontSize: 20),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: BarcodeWidget(
                barcode: Barcode.qrCode(), // Barcode type and settings
                data: serviceTable.id, // Content
                width: 128,
                height: 128,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.0),
        captainSelectWidget,
        SizedBox(height: 10.0),
        isActiveWidget(),
        SizedBox(height: 10.0),
        tableTypeToggle(context, serviceTable),
        SizedBox(height: 10.0),
        Text('seats', textAlign: TextAlign.start,),
        _pullSeats(context),
        SizedBox(height: 10.0),
      ],
    );
  }

  _pullSeats(BuildContext context) {
    final Stream<QuerySnapshot> _stream = FirestoreHelper.getSeats(
        widget.serviceId, widget.serviceTable.tableNumber);
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
              final Seat seat = Seat.fromMap(data);
              seats.add(seat);

              if (i == snapshot.data!.docs.length - 1) {
                return _displaySeats(context, seats);
              }
            }
          } else {
            // seats are not defined for table, adding them
            for (int i = 0; i < widget.serviceTable.capacity; i++) {
              Seat seat = Seat(
                  custId: "",
                  id: StringUtils.getRandomString(20),
                  serviceId: widget.serviceId,
                  tableId: widget.serviceTable.id,
                  tableNumber: widget.serviceTable.tableNumber);
              seats.add(seat);
              // BlocRepository.insertSeat(widget.dao, seat);
              FirestoreHelper.pushSeat(seat);
            }
            return _displaySeats(context, seats);
          }

          return Text('pulling seats...');
        });
  }

  _displaySeats(BuildContext context, List<Seat> seats) {
    return Expanded(
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

                  if (!seat.custId.isEmpty) {
                    logger.i('seat is occupied.');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("seat free"),
                          content: Text(
                              "would you like to make the seat available?"),
                          actions: [
                            TextButton(
                              child: Text("yes"),
                              onPressed: () {
                                FirestoreHelper.updateSeat(seat.id, '');

                                // remove the user's bloc service id field
                                FirestoreHelper.updateUserBlocId(
                                    seat.custId, '');

                                //check if all seats are empty, and mark table as not occupied
                                bool isOccupied = false;
                                for (Seat s in seats) {
                                  if (s.id == seat.id) {
                                    continue;
                                  }
                                  if (s.custId.isNotEmpty) {
                                    isOccupied = true;
                                    break;
                                  }
                                }
                                if (!isOccupied) {
                                  FirestoreHelper.setTableOccupyStatus(
                                      seat.tableId, false);
                                }

                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("no"),
                              onPressed: () {
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
                  logger.d('seat selected : ' + seat.id);
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

    if (scanCustId.compareTo('-1') == 0) {
      return;
    }

    seat.custId = scanCustId;
    FirestoreHelper.updateSeat(seat.id, scanCustId);
    FirestoreHelper.setTableOccupyStatus(widget.serviceTable.id, true);

    setState(() {
      widget.serviceTable.isOccupied = true;
    });
  }

  tableTypeToggle(BuildContext context, ServiceTable serviceTable) {
    int initialTableTypeIndex;
    if (serviceTable.type == FirestoreHelper.TABLE_COMMUNITY_TYPE_ID) {
      initialTableTypeIndex = 0;
    } else {
      initialTableTypeIndex = 1;
    }
    List<String> types = ['community', 'private'];

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('type: ', style: TextStyle(fontSize: 18)),
          ),
          Spacer(),
          ToggleSwitch(
            minWidth: 120.0,
            minHeight: 50.0,
            fontSize: 16.0,
            initialLabelIndex: initialTableTypeIndex,
            activeBgColor: [Theme.of(context).primaryColor],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.grey[900],
            totalSwitches: 2,
            labels: types,
            onToggle: (index) {
              int tableType = FirestoreHelper.TABLE_COMMUNITY_TYPE_ID;
              if (index == 1) {
                tableType = FirestoreHelper.TABLE_PRIVATE_TYPE_ID;
              }
              FirestoreHelper.setTableType(serviceTable, tableType);
            },
          ),
        ],
      ),
    );
  }

  isActiveWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        children: <Widget>[ //SizedBox
          Text(
            'active : ',
            style: TextStyle(fontSize: 18.0),
          ), //Text
          const SizedBox(width: 10), //SizedBox
          Checkbox(
            value: widget.serviceTable.isActive,
            onChanged: (value) {
              setState(() {
                widget.serviceTable.isActive =  value!;
                FirestoreHelper.setTableActiveStatus(widget.serviceTable.id, value);
              });
            },
          ), //Checkbox
        ], //<Widget>[]
      ),
    );

  }
}
