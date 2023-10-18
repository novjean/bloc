import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class PartyTixTierItem extends StatefulWidget {
  PartyTixTier partyTixTier;
  String tixId;

  PartyTixTierItem({Key? key, required this.partyTixTier, required this.tixId})
      : super(key: key);

  @override
  State<PartyTixTierItem> createState() => _PartyTixTierItemState();
}

class _PartyTixTierItemState extends State<PartyTixTierItem> {
  static const String _TAG = 'PartyTixTierItem';

  int quantity = 0;

  TixTier mTixTier = Dummy.getDummyTixTier();

  @override
  void initState() {
    mTixTier = mTixTier.copyWith(tixId: widget.tixId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.partyTixTier.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                    // leading: FadeInImage(
                    //   placeholder: const AssetImage(
                    //       'assets/icons/logo.png'),
                    //   image: NetworkImage(tixTier.imageUrl),
                    //   fit: BoxFit.cover,),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '${widget.partyTixTier.tierName}   ',
                            style: const TextStyle(
                                fontFamily: Constants.fontDefault,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('\u20B9 ${widget.partyTixTier.tierPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14)),
                        )
                      ],
                    ),
                    subtitle: Text(widget.partyTixTier.tierDescription),
                    trailing: !widget.partyTixTier.isSoldOut
                        ? DropdownButton<int>(
                            value: quantity,
                            items: List<DropdownMenuItem<int>>.generate(10,
                                (int index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text((index).toString()),
                              );
                            }),
                            onChanged: (newValue) {
                              setState(() {
                                quantity = newValue!;
                                if (quantity > 0) {
                                  FirestoreHelper.pullTix(widget.tixId)
                                      .then((res) {
                                    if (res.docs.isNotEmpty) {
                                      DocumentSnapshot document = res.docs[0];
                                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                                      Tix tix = Fresh.freshTixMap(data, false);
                                      if(tix.tixTierIds.contains(mTixTier.id)){
                                        // ticket count increased, nothing to do
                                        // TixTier info will have count

                                        // need to update tix tier
                                        FirestoreHelper.pullTixTier(mTixTier.id).then(
                                            (res) {
                                              if(res.docs.isNotEmpty){
                                                DocumentSnapshot document = res.docs[0];
                                                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                                TixTier tixTier = Fresh.freshTixTierMap(data, false);

                                                // update the quantity on this
                                                tixTier = tixTier.copyWith(
                                                    tixTierPrice:
                                                    widget.partyTixTier.tierPrice,
                                                    tixTierCount: quantity,
                                                    tixTierTotal:
                                                    widget.partyTixTier.tierPrice * quantity
                                                );
                                                FirestoreHelper.pushTixTier(tixTier);
                                              } else {
                                                // bad data, could not find tix tier
                                                // add new tix tier to db
                                                mTixTier = mTixTier.copyWith(
                                                    partyTixTierId: widget.partyTixTier.id,
                                                    tixTierName: widget.partyTixTier.tierName,
                                                    tixTierPrice:
                                                    widget.partyTixTier.tierPrice,
                                                    tixTierCount: quantity,
                                                    tixTierTotal:
                                                    widget.partyTixTier.tierPrice *
                                                        quantity);
                                                FirestoreHelper.pushTixTier(mTixTier);

                                                // no need to add it to the tix since it is already present
                                              }
                                            }
                                        );
                                      } else {
                                        mTixTier = mTixTier.copyWith(
                                            partyTixTierId: widget.partyTixTier.id,
                                            tixTierName: widget.partyTixTier.tierName,
                                            tixTierPrice:
                                            widget.partyTixTier.tierPrice,
                                            tixTierCount: quantity,
                                            tixTierTotal:
                                            widget.partyTixTier.tierPrice *
                                                quantity);
                                        FirestoreHelper.pushTixTier(mTixTier);

                                        List<String> tixTierIds = tix.tixTierIds;
                                        tixTierIds.add(mTixTier.id);
                                        tix = tix.copyWith(tixTierIds: tixTierIds);

                                        FirestoreHelper.pushTix(tix);
                                      }

                                      Logx.em(_TAG, 'tix tier data saved in firebase');

                                    } else {
                                      Logx.em(_TAG, 'tix ${widget.tixId} not found in firebase');
                                    }
                                  });


                                  //update tix
                                  FirestoreHelper.pullTix(widget.tixId)
                                      .then((res) {
                                    if (res.docs.isNotEmpty) {
                                      DocumentSnapshot document = res.docs[0];
                                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                                      Tix tix = Fresh.freshTixMap(data, false);
                                      if(tix.tixTierIds.contains(mTixTier.id)){
                                        // ticket count increased, nothing to do
                                        // TixTier info will have count
                                      } else {
                                        List<String> tixTierIds = tix.tixTierIds;
                                        tixTierIds.add(mTixTier.id);
                                        tix = tix.copyWith(tixTierIds: tixTierIds);

                                        FirestoreHelper.pushTix(tix);
                                      }

                                      Logx.em(_TAG, 'tix tier data saved in firebase');

                                    } else {
                                      Logx.em(_TAG, 'tix ${widget.tixId} not found in firebase');
                                    }
                                  });
                                } else {
                                  // delete from db
                                  FirestoreHelper.deleteTixTier(mTixTier.id);
                                }
                              });
                            },
                          )
                        : const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text('sold\nout'),
                        ))),
          ),
        ),
      ),
    );
  }
}
