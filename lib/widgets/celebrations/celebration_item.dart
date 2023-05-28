import 'package:bloc/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../db/entity/celebration.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';

class CelebrationItem extends StatelessWidget {
  static const String _TAG = 'CelebrationItem';

  final Celebration celebration;

  const CelebrationItem({Key? key, required this.celebration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        '${celebration.name.toLowerCase()} | party of ${celebration.guestsCount}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Hero(
        tag: celebration.id,
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
                            celebration.arrivalDate),
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
                          celebration.createdAt)}'),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                      child: Row(
                        children: [
                          const Text('approved: '),
                          Checkbox(
                            value: celebration.isApproved,
                            onChanged: (value) {
                              Celebration updatedCelebration = celebration.copyWith(isApproved: value);
                              Logx.i(_TAG, 'celebration for ${updatedCelebration.name} : approved $value');
                              Celebration freshCelebration = Fresh.freshCelebration(updatedCelebration);
                              FirestoreHelper.pushCelebration(freshCelebration);
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
