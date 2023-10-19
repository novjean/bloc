import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/tix/checkout_tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/dark_button_widget.dart';

class TixCheckoutScreen extends StatefulWidget {
  Tix tix;

  TixCheckoutScreen({key, required this.tix})
      : super(key: key);

  @override
  State<TixCheckoutScreen> createState() => _TixCheckoutScreenState();
}

class _TixCheckoutScreenState extends State<TixCheckoutScreen> {
  static const String _TAG = 'TixCheckoutScreen';

  Party mParty = Dummy.getDummyParty(Constants.blocServiceId);
  var _isPartyLoading = true;

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  double totalPrice = 0;

  @override
  void initState() {
    FirestoreHelper.pullParty(widget.tix.partyId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        final Party party = Fresh.freshPartyMap(data, false);
        mParty = party;

        setState(() {
          _isPartyLoading = false;
        });
      } else {
        //party not found.
        Logx.ist(_TAG, 'party could not be found');
        Navigator.of(context).pop();
      }
    });

    FirestoreHelper.pullTixTiersByTixId(widget.tix.id).then(
        (res) {
          if (res.docs.isNotEmpty) {
            List<TixTier> tixTiers = [];
            for (int i = 0; i < res.docs.length; i++) {
              DocumentSnapshot document = res.docs[i];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              final TixTier tixTier = Fresh.freshTixTierMap(data, false);
              mTixTiers.add(tixTier);

              totalPrice += tixTier.tixTierCount * tixTier.tixTierPrice;
            }

            setState(() {
              _isTixTiersLoading = false;
            });
          } else {
            Logx.em(_TAG, 'no tix tiers found for ${widget.tix.partyId}');
          }
        }
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: AppBar(
        title: AppBarTitle(title: 'checkout'),
        titleSpacing: 0,
        backgroundColor: Constants.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading && _isTixTiersLoading
        ? const LoadingWidget()
        : Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            PartyBanner(
              party: mParty,
              isClickable: false,
              shouldShowButton: false,
              isGuestListRequested: false,
              shouldShowInterestCount: false,
            ),
            _showTixTiers(context, mTixTiers),

            // widget.task == 'buy'
            //     ? _showBuyTixTiers(context)
            //     : _showTixTiers(context),
            const SizedBox(height: 70,),
          ],
        ),
        // Floating Container at the bottom
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _showTixPricePurchase(context)

            // _loadTixTiers(context)
        ),
      ],
    );
  }

  _showTixPricePurchase(BuildContext context) {
    return Container(
      color: Constants.primary,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'total  \u20B9 ${totalPrice.toStringAsFixed(0)}',
          ),
          DarkButtonWidget(
            text: 'purchase',
            onClicked: () {
              Logx.ist(_TAG, 'clicked proceed');
            },)
        ],
      ),
    );
  }

  _showTixTiers(BuildContext context, List<TixTier> tixTiers) {
    return SizedBox(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: tixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            TixTier tixTier = tixTiers[index];

            return CheckoutTixTierItem(
              tixTier: tixTier,
            );
          }),
    );
  }
}
