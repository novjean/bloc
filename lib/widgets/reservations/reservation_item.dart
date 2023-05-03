import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/reservation.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';

class ReservationItem extends StatelessWidget {
  static const String _TAG = 'ReservationItem';

  final Reservation reservation;

  const ReservationItem({Key? key, required this.reservation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        '${reservation.name.toLowerCase()} | party of ${reservation.guestsCount}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: reservation.id,
        child: Card(
          color: Theme.of(context).primaryColorLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        DateTimeUtils.getFormattedDate2(
                            reservation.arrivalDate),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text('requested at: ${DateTimeUtils.getFormattedDateYear(
                              reservation.createdAt)}'),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                      child: Row(
                        children: [
                          const Text('approved: '),
                          Checkbox(
                            value: reservation.isApproved,
                            onChanged: (value) {
                              Reservation updatedReservation =
                                  reservation.copyWith(isApproved: value);
                              Logx.i(_TAG,
                                  'reservation for ${updatedReservation.name} approved $value');
                              Reservation freshReservation =
                                  Fresh.freshReservation(updatedReservation);
                              FirestoreHelper.pushReservation(freshReservation);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
