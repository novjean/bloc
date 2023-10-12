import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/tix/tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';

class BuyTixScreen extends StatefulWidget{
  String partyId;

  BuyTixScreen(
      {key, required this.partyId})
      : super(key: key);

  @override
  State<BuyTixScreen> createState() => _BuyTixScreenState();
}

class _BuyTixScreenState extends State<BuyTixScreen> {
  static const String _TAG = 'BuyTixScreen';

  Party mParty = Dummy.getDummyParty(Constants.blocServiceId);
  var _isPartyLoading = true;

  List<PartyTixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullParty(widget.partyId).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data =
        document.data()! as Map<String, dynamic>;
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

    FirestoreHelper.pullPartyTixTiers(widget.partyId).then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyTixTier tixTier = Fresh.freshPartyTixTierMap(data, false);
          mTixTiers.add(tixTier);
        }
        setState(() {
          _isTixTiersLoading = false;
        });
      } else {
        //tix tiers are not defined
        setState(() {
          _isTixTiersLoading = false;
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
        title: AppBarTitle(title: 'buy tix'),
        titleSpacing: 0,
        backgroundColor: Constants.background,
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading
        && _isTixTiersLoading
        ?
    const LoadingWidget()
        : ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        PartyBanner(
          party: mParty,
          isClickable: false,
          shouldShowButton: false,
          isGuestListRequested: false,
          shouldShowInterestCount: false,
        ),
        _showTixTiers(context),

      ],
    );
  }

  _showTixTiers(BuildContext context) {
    return SizedBox(
      // height: mq.height * 0.35,
      // width: mq.width * 0.99,
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: mTixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            PartyTixTier tixTier = mTixTiers[index];

            return TixTierItem(
              tixTier: tixTier,
            );
          }),
    );
  }
}