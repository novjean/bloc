import 'package:barcode_widget/barcode_widget.dart';
import 'package:bloc/db/entity/service_table.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/seat.dart';
import '../../../db/entity/user.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ui/button_widget.dart';
import 'manage_seats_screen.dart';

class TableAddEditScreen extends StatefulWidget {
  ServiceTable table;
  String task;

  TableAddEditScreen({key, required this.table, required this.task})
      : super(key: key);

  @override
  _TableAddEditScreenState createState() => _TableAddEditScreenState();
}

class _TableAddEditScreenState extends State<TableAddEditScreen> {
  // bool isPhotoChanged = false;
  // late String oldImageUrl;
  // late String newImageUrl;
  // String imagePath = '';

  List<User> captains = [];
  List<String> userCaptainNames = [];
  late String _sUserCaptainName;
  late String _sUserCaptainId;
  bool _isUserCaptainsLoading = true;

  bool isCapacityChanged = false;
  int seatCapacityChange = 0;

  List<String> tableTypes = ['private', 'community'];
  String sTableType = 'private';

  @override
  void initState() {
    super.initState();

    sTableType = widget.table.type == FirestoreHelper.TABLE_PRIVATE_TYPE_ID
        ? 'private'
        : 'community';

    FirestoreHelper.pullUsersByLevel(Constants.CAPTAIN_LEVEL).then((res) {
      print("successfully pulled in all captains ");

      if (res.docs.isNotEmpty) {
        List<User> _captains = [];
        List<String> _captainNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = User.fromMap(data);

          if (i == 0) {
            _sUserCaptainId = user.id;
            _sUserCaptainName = user.name;
          }

          _captainNames.add(user.name);
          _captains.add(user);
        }

        setState(() {
          userCaptainNames = _captainNames;
          captains = _captains;
          _isUserCaptainsLoading = false;
        });
      } else {
        print('no captains found!');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('table | ' + widget.task),
        ),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return _isUserCaptainsLoading
        ? Center(
            child: Text('tables loading...'),
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(), // Barcode type and settings
                  data: widget.table.id, // Content
                  width: 128,
                  height: 128,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('table_number'),
                initialValue: widget.table.tableNumber.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'enter a valid table number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'number',
                ),
                onChanged: (value) {
                  int? newNumber = int.tryParse(value);
                  widget.table = widget.table.copyWith(tableNumber: newNumber);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('table_capacity'),
                initialValue: widget.table.capacity.toString(),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enableSuggestions: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'enter a valid seat count for the table';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'capacity',
                ),
                onChanged: (value) {
                  int? newCapacity = int.tryParse(value);
                  seatCapacityChange = newCapacity! - widget.table.capacity;
                  widget.table = widget.table.copyWith(capacity: newCapacity);
                },
              ),
              const SizedBox(height: 24),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('table_type'),
                    decoration: InputDecoration(
                        errorStyle: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontSize: 16.0),
                        hintText: 'select table type',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: sTableType == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sTableType,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            sTableType = newValue!;

                            widget.table = widget.table.copyWith(
                                type: sTableType == 'private'
                                    ? FirestoreHelper.TABLE_PRIVATE_TYPE_ID
                                    : FirestoreHelper.TABLE_COMMUNITY_TYPE_ID);
                            state.didChange(newValue);
                          });
                        },
                        items: tableTypes.map((String value) {
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
              const SizedBox(height: 24),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('captain_select'),
                    decoration: InputDecoration(
                        errorStyle: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontSize: 16.0),
                        hintText: 'select captain',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: _sUserCaptainName == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sUserCaptainName,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _sUserCaptainName = newValue!;

                            for (User user in captains) {
                              if (user.name == _sUserCaptainName) {
                                _sUserCaptainId = user.id;
                              }
                            }

                            widget.table = widget.table
                                .copyWith(captainId: _sUserCaptainId);
                            state.didChange(newValue);
                          });
                        },
                        items: userCaptainNames.map((String value) {
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
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  //SizedBox
                  Text(
                    'occupied : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.table.isOccupied,
                    onChanged: (value) {
                      setState(() {
                        //todo: clear up all seats
                        widget.table = widget.table.copyWith(isOccupied: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  //SizedBox
                  Text(
                    'active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.table.isActive,
                    onChanged: (value) {
                      setState(() {
                        widget.table = widget.table.copyWith(isActive: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'save',
                onClicked: () {
                  if (seatCapacityChange > 0) {
                    for(int i = 0; i<seatCapacityChange; i++){
                      // seat is added
                      Seat seat = Dummy.getDummySeat(
                          widget.table.serviceId, UserPreferences.myUser.id);
                      seat.tableId = widget.table.id;
                      seat.tableNumber = widget.table.tableNumber;
                      seat.custId = '';
                      FirestoreHelper.pushSeat(seat);
                    }
                    FirestoreHelper.pushTable(widget.table);
                    Navigator.of(context).pop();
                  } else if (seatCapacityChange < 0) {
                    // seat is removed
                    // determine the count
                    FirestoreHelper.pullSeats(widget.table.id).then((res) {
                      print('successfully pulled in seats');

                      if (res.docs.isNotEmpty) {
                        // found parties
                        List<Seat> seats = [];
                        for (int i = 0; i < res.docs.length; i++) {
                          DocumentSnapshot document = res.docs[i];
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          final Seat seat = Seat.fromMap(data);
                          seats.add(seat);
                        }

                        int seatsToBeRemoved = seats.length - widget.table.capacity;
                        for(Seat seat in seats){
                          if(seat.custId.isEmpty){
                            FirestoreHelper.deleteSeat(seat);
                            seatsToBeRemoved--;
                            if(seatsToBeRemoved==0) {
                              break;
                            }
                          }
                        }

                        FirestoreHelper.pushTable(widget.table);
                        Navigator.of(context).pop();
                      } else {
                        print('no seats found!');
                      }
                    });
                  } else {
                    FirestoreHelper.pushTable(widget.table);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(text: 'seats', onClicked: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ManageSeatsScreen(
                    serviceId: widget.table.serviceId,
                    serviceTable: widget.table,
                  ),
                ));
              }),
            ],
          );
  }
}
