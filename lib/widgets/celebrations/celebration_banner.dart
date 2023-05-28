import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:flutter/material.dart';

import '../../db/entity/celebration.dart';
import '../../db/entity/reservation.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../screens/user/celebration_add_edit_screen.dart';
import '../../screens/user/reservation_add_edit_screen.dart';
import '../../utils/logx.dart';

class CelebrationBanner extends StatelessWidget {
  static const String _TAG = 'CelebrationBanner';
  final Celebration celebration;
  final bool isPromoter;

  const CelebrationBanner(
      {Key? key, required this.celebration, required this.isPromoter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = celebration.name.toLowerCase() +
        (celebration.guestsCount > 1
            ? ' + ${celebration.guestsCount - 1}'
            : '');
    return Hero(
      tag: celebration.id,
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
                          Flexible(
                            flex: 2,
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(
                              DateTimeUtils.getFormattedDate(
                                  celebration.arrivalDate),
                              style: const TextStyle(fontSize: 18),
                            ),
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
                            '+${celebration.phone}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            celebration.arrivalTime,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 5.0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ButtonWidget(
                            text: 'edit',
                            onClicked: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => CelebrationAddEditScreen(
                                        celebration: celebration,
                                        task: 'edit',
                                      )));
                            },
                          ),
                          isPromoter
                              ? celebration.isApproved
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: DarkButtonWidget(
                                          text: 'decline',
                                          onClicked: () {
                                            bool value = false;
                                            Celebration updatedCelebration =
                                                celebration.copyWith(
                                                    isApproved: value);
                                            Logx.i(_TAG,
                                                'celebration for ${updatedCelebration.name} approved $value');
                                            Celebration freshCelebration =
                                                Fresh.freshCelebration(
                                                    updatedCelebration);
                                            FirestoreHelper.pushCelebration(
                                                freshCelebration);
                                          }),
                                    )
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: ButtonWidget(
                                        text: 'approve',
                                        onClicked: () {
                                          bool value = true;
                                          Celebration updatedCelebration =
                                              celebration.copyWith(
                                                  isApproved: value);
                                          Logx.i(_TAG,
                                              'celebration for ${updatedCelebration.name} approved $value');
                                          Celebration freshCelebration =
                                              Fresh.freshCelebration(
                                                  updatedCelebration);
                                          FirestoreHelper.pushCelebration(
                                              freshCelebration);
                                        },
                                      ),
                                    )
                              : const SizedBox()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
