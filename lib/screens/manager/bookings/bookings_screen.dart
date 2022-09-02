import 'package:flutter/material.dart';

import '../../../db/dao/bloc_dao.dart';

class BookingsScreen extends StatefulWidget {
  BlocDao dao;
  String blocServiceId;
  String serviceName;
  String userTitle;


  BookingsScreen({required this.blocServiceId,
    required this.dao,
    required this.serviceName,
    required this.userTitle});

  @override
  State<StatefulWidget> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.userTitle + ' | ' + widget.serviceName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //todo: implement new booking
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //       builder: (ctx) =>
          //           NewServiceTableScreen(serviceId: widget.blocServiceId)),
          // );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        tooltip: 'New Booking',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 2.0),
        // _displayOptions(context),
        // const Divider(),
        SizedBox(height: 2.0),
        _buildBookings(context),
        SizedBox(height: 2.0),
      ],
    );
  }

  _buildBookings(BuildContext context) {
    return Expanded(child: Center(child: Text('Bookings loading...')),);


    // return StreamBuilder(stream:, builder: (ctx, snapshot) {
    //   return Container(child: Center(child: Text('Bookings loading...')),);
    // });
  }
}