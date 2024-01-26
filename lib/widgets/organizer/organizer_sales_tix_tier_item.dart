import 'package:bloc/db/entity/party_tix_tier.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class OrganizerSalesTixTierItem extends StatelessWidget{
  static const String _TAG = 'OrganizerSalesTixTierItem';

  PartyTixTier partyTixTier;

  OrganizerSalesTixTierItem({Key? key, required this.partyTixTier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = partyTixTier.soldCount * partyTixTier.tierPrice;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: partyTixTier.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: Text('${partyTixTier.soldCount}',
                    style: const TextStyle(
                      fontFamily: Constants.fontDefault,
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),),
                  title: RichText(
                    text: TextSpan(
                      text: '${partyTixTier.tierName} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('${StringUtils.rs} ${partyTixTier.tierPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${StringUtils.rs} ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

}