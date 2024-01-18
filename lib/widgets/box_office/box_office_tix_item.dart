
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/tix_tier_item.dart';
import '../../helpers/fresh.dart';
import '../../screens/box_office/box_office_tix_screen.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class BoxOfficeTixItem extends StatefulWidget {
  Tix tix;
  final Party party;
  final bool isClickable;

  BoxOfficeTixItem(
      {Key? key,
        required this.tix,
        required this.isClickable,
        required this.party})
      : super(key: key);

  @override
  State<BoxOfficeTixItem> createState() => _BoxOfficeTixItemState();
}

class _BoxOfficeTixItemState extends State<BoxOfficeTixItem> {
  static const String _TAG = 'BoxOfficeTixItem';

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;
  int count = 0;

  @override
  void initState() {
    FirestoreHelper.pullTixTiersByTixId(widget.tix.id).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
          mTixTiers.add(tixTier);

          count += tixTier.tixTierCount;
        }

        setState(() {
          _isTixTiersLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no tix tiers found for tix id ${widget.tix.id}');

        setState(() {
          _isTixTiersLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.party.id,
      child: Card(
        elevation: 1,
        color: Constants.lightPrimary,
        child: SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 3, left: 5.0, right: 0.0),
                      child: Text(
                        widget.party.name.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 5),
                      child: Text(
                        '$count tickets',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        widget.party.isTBA
                            ? 'tba'
                            : '🎊 ${DateTimeUtils.getFormattedDate(widget.party.startTime)}, ${DateTimeUtils.getFormattedTime(widget.party.startTime)}' ,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text('🚪${DateTimeUtils.getFormattedDate(widget.party.endTime)}, ${DateTimeUtils.getFormattedTime(widget.party.endTime)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              height: 60,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.background,
                                  foregroundColor: Constants.primary,
                                  shadowColor: Colors.white30,
                                  minimumSize: const Size.fromHeight(60),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                  ),
                                  elevation: 3,
                                ),
                                label: const Text('see ticket', style: TextStyle(fontSize: 18),),
                                icon: const Icon(
                                  Icons.qr_code_sharp,
                                  size: 24.0,
                                ),
                                onPressed: () {
                                  // _showTixDialog(context);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => BoxOfficeTixScreen(tixId: widget.tix.id)));
                                },
                              ),
                            )
                        ),
                      ],)
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Constants.primary),
                    borderRadius: const BorderRadius.all(Radius.circular(1)),
                    image: DecorationImage(
                      image: NetworkImage(widget.party.imageUrl),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
