import 'package:bloc/db/entity/tix.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix_tier_item.dart';
import '../../helpers/fresh.dart';
import '../../screens/box_office/promoter_box_office_tix_screen.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class PromoterTixDataItem extends StatefulWidget {
  Tix tix;
  final Party party;
  final bool isClickable;

  PromoterTixDataItem(
      {Key? key,
        required this.tix,
        required this.isClickable,
        required this.party,})
      : super(key: key);

  @override
  State<PromoterTixDataItem> createState() => _PromoterTixDataItemState();
}

class _PromoterTixDataItemState extends State<PromoterTixDataItem> {
  static const String _TAG = 'PromoterTixDataItem';

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  int tixCount = 0;

  @override
  void initState() {
    FirestoreHelper.pullTixTiersByTixId(widget.tix.id).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
          mTixTiers.add(tixTier);

          tixCount += tixTier.tixTierCount;
        }

        setState(() {
          _isTixTiersLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no tix tiers found for tix id ${widget.tix.id}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title =
        widget.tix.userName.toLowerCase();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PromoterBoxOfficeTixScreen(tixId: widget.tix.id)));

        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         backgroundColor: Constants.lightPrimary,
        //         shape: const RoundedRectangleBorder(
        //             borderRadius: BorderRadius.all(Radius.circular(10.0))),
        //         contentPadding: const EdgeInsets.all(10.0),
        //         title: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Text(widget.tix.userName),
        //             Text('\u20B9 ${widget.tix.total.toStringAsFixed(0)}'),
        //           ],
        //         ),
        //         content: Container(
        //           height: (100 * mTixTiers.length).toDouble(), // Change as per your requirement
        //           width: 300, // Change as per your requirement
        //           child: ListView.builder(
        //             shrinkWrap: true,
        //             itemCount: mTixTiers.length,
        //             itemBuilder: (BuildContext context, int index) {
        //               TixTier tixTier = mTixTiers[index];
        //
        //               return ListTile(
        //                 title: Text(tixTier.tixTierName),
        //                 subtitle: Text('${tixTier.tixTierCount} x ${tixTier.tixTierPrice}'),
        //               );
        //             },
        //           ),
        //         ),
        //       );
        //     });
      },
      child: Hero(
        tag: widget.tix.id,
        child: Card(
          elevation: 1,
          color: Constants.lightPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                        _isTixTiersLoading ? const SizedBox() : Text(
                          tixCount.toString(),
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        )
                      ],
                    ),
                    Text(
                      '+${widget.tix.userPhone}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
