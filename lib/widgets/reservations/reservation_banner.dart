import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:flutter/material.dart';

import '../../db/entity/reservation.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../screens/user/reservation_add_edit_screen.dart';
import '../../utils/logx.dart';

class ReservationBanner extends StatelessWidget {
  static const String _TAG = 'ReservationBanner';
  final Reservation reservation;

  const ReservationBanner({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = reservation.name.toLowerCase() +
        (reservation.guestsCount > 1
            ? ' + ${reservation.guestsCount - 1}'
            : '');
    return Hero(
      tag: reservation.id,
      child: Card(
        elevation: 1,
        color: Theme.of(context).primaryColorLight,
        child: SizedBox(
          height: 130,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(top: 3, left: 5.0, right: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            DateTimeUtils.getFormattedDate(
                                reservation.arrivalDate),
                            style: const TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '+${reservation.phone}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            reservation.arrivalTime,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ButtonWidget(
                            text: 'edit',
                            onClicked: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => ReservationAddEditScreen(
                                        reservation: reservation,
                                        task: 'edit',
                                      )));
                            },
                          ),
                          reservation.isApproved
                              ? Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: DarkButtonWidget(
                                    text: 'decline',
                                    onClicked: () {
                                      bool value = false;
                                      Reservation updatedReservation =
                                          reservation.copyWith(isApproved: value);
                                      Logx.i(_TAG,
                                          'reservation for ${updatedReservation.name} approved $value');
                                      Reservation freshReservation =
                                          Fresh.freshReservation(
                                              updatedReservation);
                                      FirestoreHelper.pushReservation(
                                          freshReservation);
                                    }),
                              )
                              : Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: ButtonWidget(
                                    text: 'approve',
                                    onClicked: () {
                                      bool value = true;
                                      Reservation updatedReservation =
                                          reservation.copyWith(isApproved: value);
                                      Logx.i(_TAG,
                                          'reservation for ${updatedReservation.name} approved $value');
                                      Reservation freshReservation =
                                          Fresh.freshReservation(
                                              updatedReservation);
                                      FirestoreHelper.pushReservation(
                                          freshReservation);
                                    },
                                  ),
                              )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // Flexible(
              //   flex: 1,
              //   child: Container(
              //     height: 200,
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Theme.of(context).primaryColor),
              //       borderRadius: BorderRadius.all(Radius.circular(0)),
              //       image: DecorationImage(
              //         image: NetworkImage(reservation.imageUrl),
              //         fit: BoxFit.fitHeight,
              //         // AssetImage(food['image']),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
