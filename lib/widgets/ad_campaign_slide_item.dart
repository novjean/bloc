import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';

class AdCampaignSlideItem extends StatelessWidget {
  AdCampaign adCampaign;

  AdCampaignSlideItem({Key? key, required this.adCampaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final uri = Uri.parse(adCampaign.linkUrl);
        NetworkUtils.launchInBrowser(uri);

        adCampaign.adClick++;
        FirestoreHelper.pushAdCampaign(adCampaign);
      },
      child: Hero(
        tag: adCampaign.id,
        child: Card(
          elevation: 3,
          color: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Stack(children: [
            Container(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 400,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 500),
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  // aspectRatio: 2.0,
                ),
                items: adCampaign.imageUrls
                    .map((item) => Center(
                        child: Image.network(item,
                            fit: BoxFit.fitHeight,
                            // height: mq.height * 0.50,
                            width: mq.width)))
                    .toList(),
              ),
            ),
            const Positioned(
              right: 5,
              top: 10,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  '#itsHoppilicious',
                  style: TextStyle(color: Constants.hopp, fontSize: 30),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
