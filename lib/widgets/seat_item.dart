import 'package:bloc/db/entity/seat.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/entity/user.dart';
import '../helpers/dummy.dart';
import '../helpers/fresh.dart';

class SeatItem extends StatefulWidget {
  final Seat seat;

  SeatItem({required this.seat});

  @override
  State<SeatItem> createState() => _SeatItemState();
}

class _SeatItemState extends State<SeatItem> {
  User user = Dummy.getDummyUser();
  bool isCustomerLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.seat.custId.isNotEmpty) {
      FirestoreHelper.pullUser(widget.seat.custId).then((res) {
        print('successfully pulled in user for id ' + widget.seat.custId);

        if (res.docs.isNotEmpty) {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          final User _user = Fresh.freshUserMap(data, true);

          setState(() {
            user = _user;
            isCustomerLoading = false;
          });
        }
      });
    } else {
      setState(() {
        isCustomerLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 10;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.2, 0.7],
                  colors: [
                    Color.fromARGB(100, 0, 0, 0),
                    Color.fromARGB(100, 0, 0, 0),
                  ],
                  // stops: [0.0, 0.1],
                ),
              ),
              height: height,
              width: width,
            ),
            Center(
              child: Container(
                height: height,
                width: width,
                padding: const EdgeInsets.all(1),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: isCustomerLoading
                    ? LoadingWidget()
                    : Center(
                        child: Text(
                          widget.seat.custId.isEmpty
                              ? 'free'
                              : user.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
