import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../widgets/organizer/organizer_sales_tix_tier_item.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/ui/loading_widget.dart';

class OrganizerPartySalesScreen extends StatefulWidget {
  final Party party;

  const OrganizerPartySalesScreen({super.key, required this.party});

  @override
  State<OrganizerPartySalesScreen> createState() => _OrganizerPartySalesScreenState();
}

class _OrganizerPartySalesScreenState extends State<OrganizerPartySalesScreen> {
  static const String _TAG = 'OrganizerPartySalesScreen';

  List<PartyTixTier> mPartyTixTiers = [];
  var _isPartyTixTiersLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullPartyTixTiers(widget.party.id).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyTixTier partyTixTier = Fresh.freshPartyTixTierMap(data, false);
          mPartyTixTiers.add(partyTixTier);
        }
        setState(() {
          _isPartyTixTiersLoading = false;
        });
      } else {
        //tix tiers are not defined
        setState(() {
          _isPartyTixTiersLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'sales',),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyTixTiersLoading
        ? const LoadingWidget()
        : Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            PartyBanner(
              party: widget.party,
              isClickable: false,
              shouldShowButton: false,
              isGuestListRequested: false,
              shouldShowInterestCount: false,
            ),
            _displayTixTiers(context),
            const SizedBox(
              height:90,
            ),
          ],
        ),
        // Floating Container at the bottom
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _showTixPricePurchase(context)),
      ],
    );  }

  _displayTixTiers(BuildContext context) {
    return SizedBox(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: mPartyTixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return OrganizerSalesTixTierItem(
              partyTixTier: mPartyTixTiers[index],
            );
          }),
    );
  }

  _showTixPricePurchase(BuildContext context) {
    double total = 0;
    for(PartyTixTier partyTixTier in mPartyTixTiers){
      total += (partyTixTier.tierPrice * partyTixTier.soldCount);
    }

    double bookingFee = total * widget.party.bookingFeePercent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Container(
        //   color: Constants.primary,
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       const Text(
        //         'IGST',
        //       ),
        //       Text('\u20B9 ${igst.toStringAsFixed(2)}')
        //     ],
        //   ),
        // ),
        // Container(
        //   color: Constants.primary,
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       const Text(
        //         'sub-total',
        //       ),
        //       Text('\u20B9 ${subTotal.toStringAsFixed(2)}')
        //     ],
        //   ),
        // ),
        const SizedBox(height: 100,),
        UserPreferences.myUser.clearanceLevel>=Constants.MANAGER_LEVEL ? Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'booking fee',
              ),
              Text('\u20B9 ${bookingFee.toStringAsFixed(2)}')
            ],
          ),
        ) : const SizedBox(),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\u20B9 ${total.toStringAsFixed(2)}',
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ],
    );
  }

}