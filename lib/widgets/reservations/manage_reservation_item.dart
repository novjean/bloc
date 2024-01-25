import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/reservation.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class ManageReservationItem extends StatelessWidget {
  static const String _TAG = 'ManageReservationItem';

  final Reservation reservation;

  const ManageReservationItem({Key? key, required this.reservation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        '${reservation.name.toLowerCase()} | ${reservation.phone}  [${reservation.guestsCount}👫]';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: reservation.id,
        child: Card(
          color: Constants.lightPrimary,
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
                        style: const TextStyle(fontSize: 20),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('requested at: ${DateTimeUtils.getFormattedDateYear(
                              reservation.createdAt)}'),
                      Row(
                        children: [
                          const Text('approved: '),
                          Checkbox(
                            value: reservation.isApproved,
                            onChanged: (value) {
                              Logx.ist(_TAG, 'approve status cannot be changed here!');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
