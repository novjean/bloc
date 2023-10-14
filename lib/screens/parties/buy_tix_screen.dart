import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/tix/party_tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';

class BuyTixScreen extends StatefulWidget {
  String partyId;

  BuyTixScreen({key, required this.partyId}) : super(key: key);

  @override
  State<BuyTixScreen> createState() => _BuyTixScreenState();
}

class _BuyTixScreenState extends State<BuyTixScreen> {
  static const String _TAG = 'BuyTixScreen';

  Tix mTix = Dummy.getDummyTix();

  Party mParty = Dummy.getDummyParty(Constants.blocServiceId);
  var _isPartyLoading = true;

  List<PartyTixTier> mPartyTixTiers = [];
  var _isPartyTixTiersLoading = true;

  @override
  void initState() {
    mTix = mTix.copyWith(
      partyId: widget.partyId,
    );

    FirestoreHelper.pushTix(mTix);

    FirestoreHelper.pullParty(widget.partyId).then((res) {
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

    FirestoreHelper.pullPartyTixTiers(widget.partyId).then((res) {
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
        title: AppBarTitle(title: 'buy tix'),
        titleSpacing: 0,
        backgroundColor: Constants.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            for(String tixTierId in mTix.tixTierIds){
              FirestoreHelper.deleteTixTier(tixTierId);
            }
            FirestoreHelper.deleteTix(mTix.id);
            Logx.d(_TAG, 'tix deleted from firebase');

            if (kIsWeb) {
              GoRouter.of(context).pushNamed(RouteConstants.eventRouteName,
                  params: {
                    'partyName': mParty.name,
                    'partyChapter': mParty.chapter
                  });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading && _isPartyTixTiersLoading
        ? const LoadingWidget()
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
      child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: mPartyTixTiers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            PartyTixTier partyTixTier = mPartyTixTiers[index];

            return PartyTixTierItem(
              partyTixTier: partyTixTier,
              tixId: mTix.id,
            );
          }),
    );
  }
}
