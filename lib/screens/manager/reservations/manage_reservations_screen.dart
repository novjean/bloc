import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/reservation.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/reservations/reservation_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../user/reservation_add_edit_screen.dart';

class ManageReservationsScreen extends StatefulWidget {
  String blocServiceId;
  String serviceName;
  String userTitle;

  ManageReservationsScreen(
      {required this.blocServiceId,
      required this.serviceName,
      required this.userTitle});

  @override
  State<StatefulWidget> createState() => _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  static const String _TAG = 'ManageReservationsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(
          title: 'manage reservations',
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //todo: implement new booking
      //     // Navigator.of(context).push(
      //     //   MaterialPageRoute(
      //     //       builder: (ctx) =>
      //     //           NewServiceTableScreen(serviceId: widget.blocServiceId)),
      //     // );
      //   },
      //   backgroundColor: Theme.of(context).primaryColor,
      //   tooltip: 'new reservation',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.black,
      //     size: 29,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 2.0),
        // _displayOptions(context),
        // const Divider(),
        const SizedBox(height: 5.0),
        _buildReservations(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildReservations(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getReservationsByBlocId(widget.blocServiceId),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:{
            List<Reservation> reservations = [];

            if (snapshot.data!.docs.isNotEmpty) {
              try {
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map =
                  document.data()! as Map<String, dynamic>;
                  final Reservation reservation =
                  Fresh.freshReservationMap(map, false);
                  reservations.add(reservation);
                }
                return _displayReservations(context, reservations);

              } on Exception catch (e, s) {
                Logx.e(_TAG, e, s);
              } catch (e) {
                Logx.est(_TAG, 'error loading reservations : $e');
              }
            }
            else {
              Logx.est(_TAG, 'no reservations could be found!');
            }
          }
          }



          return const LoadingWidget();
        });
  }

  _displayReservations(BuildContext context, List<Reservation> reservations) {
    return Expanded(
      child: ListView.builder(
          itemCount: reservations.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Reservation reservation = reservations[index];

            return GestureDetector(
                child: ReservationItem(
                  reservation: reservation,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ReservationAddEditScreen(
                            reservation: reservation,
                            task: 'manage',
                          )));
                });
          }),
    );
  }
}
