import 'package:bloc/db/entity/tix_tier_item.dart';
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
import '../../widgets/tix/tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';

class TixBuyEditScreen extends StatefulWidget {
  Tix tix;
  String task;

  TixBuyEditScreen({key, required this.tix, required this.task}) : super(key: key);

  @override
  State<TixBuyEditScreen> createState() => _TixBuyEditScreenState();
}

class _TixBuyEditScreenState extends State<TixBuyEditScreen> {
  static const String _TAG = 'BuyTixScreen';

  Party mParty = Dummy.getDummyParty(Constants.blocServiceId);
  var _isPartyLoading = true;

  List<PartyTixTier> mPartyTixTiers = [];
  var _isPartyTixTiersLoading = true;

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

    FirestoreHelper.pullPartyTixTiers(widget.tix.partyId).then((res) {
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

    FirestoreHelper.pushTix(widget.tix);
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
            if(widget.task == 'buy'){
              for(String tixTierId in widget.tix.tixTierIds){
                FirestoreHelper.deleteTixTier(tixTierId);
              }
              FirestoreHelper.deleteTix(widget.tix.id);
              Logx.d(_TAG, 'tix deleted from firebase');
            }

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
              widget.task=='buy'?_showBuyTixTiers(context):_showTixTiers(context)
            ],
          );
  }

  _showBuyTixTiers(BuildContext context) {
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
              tixId: widget.tix.id,
            );
          }),
    );
  }

  _showTixTiers(BuildContext context) {
    if(widget.tix.tixTierIds.isNotEmpty){
      FirestoreHelper.pullTixTiers(widget.tix.partyId).then((res){
        if(res.docs.isNotEmpty) {
          List<TixTier> tixTiers = [];
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            final TixTier tixTier = Fresh.freshTixTierMap(data, false);

            if(widget.tix.tixTierIds.contains(tixTier.id)){
              tixTiers.add(tixTier);
            }
          }

          return SizedBox(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: tixTiers.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (ctx, index) {
                  TixTier tixTier = tixTiers[index];

                  return TixTierItem(
                    tixTier: tixTier,
                  );
                }),
          );

        } else {
          Logx.em(_TAG,'no tix tiers found for ${widget.tix.partyId}');
        }
      });
    } else {
      return Text('nothing to show');
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Constants.lightPrimary,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
            EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('pick or click 🤳 your best photo 🤩',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                ],
              )
            ],
          );
        });
  }

}
