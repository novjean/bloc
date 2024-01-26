import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';

class ManageAdCampaignItem extends StatelessWidget{
  static const String _TAG = 'ManageAdCampaignItem';

  AdCampaign adCampaign;

  ManageAdCampaignItem({Key? key, required this.adCampaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // double conversion = ad.hits/ad.reach;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: adCampaign.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading:
                  adCampaign.imageUrls.isNotEmpty?
                  FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(adCampaign.imageUrls[0]),
                    fit: BoxFit.cover,) : const SizedBox(),
                  title: RichText(
                    text: TextSpan(
                      text: '${adCampaign.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${adCampaign.views} 👁️'),
                      Text('${adCampaign.clickCount} hits'),
                      Text('party: ${adCampaign.isPartyAd}'),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      '${DateTimeUtils.getFormattedDate(adCampaign.endTime)} ',
                      style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
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