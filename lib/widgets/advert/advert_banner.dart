import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../db/entity/ad_campaign.dart';
import '../../db/entity/advert.dart';
import '../../db/entity/bloc.dart';
import '../../db/entity/bloc_service.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_interest.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../screens/advertise/advert_add_edit_screen.dart';
import '../../screens/manager/adverts/advert_checkout_screen.dart';
import '../../screens/manager/organizers/organizer_party_add_edit_screen.dart';
import '../../screens/organizer/organizer_party_sales_screen.dart';
import '../../screens/organizer/organizer_party_tickets_screen.dart';
import '../../utils/logx.dart';

class AdvertBanner extends StatefulWidget {
  Advert advert;

  AdvertBanner(
      {Key? key,
        required this.advert,})
      : super(key: key);

  @override
  State<AdvertBanner> createState() => _AdvertBannerState();
}

class _AdvertBannerState extends State<AdvertBanner> {
  static const String _TAG = 'AdvertBanner';

  late AdCampaign mAdCampaign;
  bool _isAdCampaignLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullAdCampaignByAdvertId(widget.advert.id).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        setState(() {
          mAdCampaign = Fresh.freshAdCampaignMap(data, true);
          _isAdCampaignLoading = false;
        });

        Logx.d(_TAG, 'ad campaign is found');
      } else {
        Logx.d(_TAG, 'ad campaign not found for ${widget.advert.id}');
      }
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) =>
                AdvertAddEditScreen(advert: widget.advert, task: 'edit')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Hero(
            tag: widget.advert.id,
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(widget.advert.title.toLowerCase(),
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Constants.fontDefault,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text('status: ${widget.advert.isActive ? 'live':'pending approval'}',
                                style: const TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              '${DateTimeUtils.getFormattedDate(widget.advert.startTime)}, ${DateTimeUtils.getFormattedTime(widget.advert.startTime)}',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          const Spacer(),
                          _isAdCampaignLoading ? const SizedBox() : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5, bottom: 1),
                                child: DelayedDisplay(
                                  delay: const Duration(seconds: 1),
                                  child: Text('${mAdCampaign.views} 👁️',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          widget.advert.isCompleted && widget.advert.isSuccess ?
                          _displayPauseEditRow() : _displayPurchaseEditRow()
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Stack(children: [
                        Container(
                          height: 200,
                          color: Constants.background,
                          child: kIsWeb
                              ? FadeInImage(
                            placeholder:
                            const AssetImage('assets/icons/logo.png'),
                            image: NetworkImage(widget.advert.imageUrls[0]),
                            fit: BoxFit.cover,
                          )
                              : CachedNetworkImage(
                            imageUrl: widget.advert.imageUrls[0],
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) =>
                            const FadeInImage(
                              placeholder:
                              AssetImage('assets/images/logo.png'),
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _displayPauseEditRow() {
    return Row(
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
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  elevation: 3,
                ),
                label: Text(
                  widget.advert.isPaused ? 'play' : 'pause',
                  style: const TextStyle(fontSize: 18),
                ),
                icon: Icon(
                  widget.advert.isPaused ? Icons.play_arrow : Icons.pause,
                  size: 24.0,
                ),
                onPressed: () {
                  if(widget.advert.isPaused){
                    // play
                    setState(() {
                      widget.advert = widget.advert.copyWith(isPaused: false);
                    });
                    FirestoreHelper.pushAdvert(widget.advert);
                    Logx.ilt(_TAG, 'ad is live now!');
                  } else {
                    // pause
                    setState(() {
                      widget.advert = widget.advert.copyWith(isPaused: true);
                    });
                    FirestoreHelper.pushAdvert(widget.advert);
                    Logx.ilt(_TAG, 'ad is paused!');
                  }
                },
              ),
            )),
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
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  elevation: 3,
                ),
                label: const Text(
                  'edit',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(
                  Icons.edit,
                  size: 24.0,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            AdvertAddEditScreen(
                              advert: widget.advert,
                              task: 'edit',
                            )),
                  );
                },
              ),
            )),
      ],
    );
  }

  _displayPurchaseEditRow() {
    return Row(
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
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  elevation: 3,
                ),
                label: const Text(
                  'buy',
                  style: TextStyle(fontSize: 18),
                ),
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  size: 24.0,
                ),
                onPressed: () async {
                  int timeDiff = widget.advert.endTime - widget.advert.startTime;
                  double days = (timeDiff/DateTimeUtils.millisecondsDay);

                  double totalAmount = days * 10;

                  double igst = totalAmount * Constants.igstPercent;
                  double subTotal = totalAmount - igst;
                  double bookingFee = totalAmount * 0;
                  double grandTotal = subTotal + igst + bookingFee;

                  widget.advert = widget.advert.copyWith(
                      igst: igst,
                      subTotal: subTotal,
                      bookingFee: bookingFee,
                      total: grandTotal);
                  Advert freshAdvert = Fresh.freshAdvert(widget.advert);
                  await FirestoreHelper.pushAdvert(freshAdvert);

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            AdvertCheckoutScreen(
                              advert: widget.advert,
                            )),
                  );
                },
              ),
            )),
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
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  elevation: 3,
                ),
                label: const Text(
                  'edit',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(
                  Icons.edit,
                  size: 24.0,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            AdvertAddEditScreen(
                              advert: widget.advert,
                              task: 'edit',
                            )),
                  );
                },
              ),
            )),
      ],
    );
  }

}
