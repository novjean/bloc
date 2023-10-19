import 'package:bloc/db/entity/tix_tier_item.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_banner.dart';
import '../../widgets/tix/checkout_tix_tier_item.dart';
import '../../widgets/tix/party_tix_tier_item.dart';
import '../../widgets/tix/buy_tix_tier_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/dark_button_widget.dart';

class TixCheckoutScreen extends StatefulWidget {
  Tix tix;
  // List<TixTier> tixTiers;

  TixCheckoutScreen({key, required this.tix})
      : super(key: key);

  @override
  State<TixCheckoutScreen> createState() => _TixCheckoutScreenState();
}

class _TixCheckoutScreenState extends State<TixCheckoutScreen> {
  static const String _TAG = 'TixCheckoutScreen';

  Party mParty = Dummy.getDummyParty(Constants.blocServiceId);
  var _isPartyLoading = true;

  List<PartyTixTier> mPartyTixTiers = [];
  var _isPartyTixTiersLoading = true;

  // List<TixTier> mTixTiers = [];
  // var _isTixTiersLoading = true;

  @override
  void initState() {
    // FirestoreHelper.pushTix(widget.tix);

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
          final PartyTixTier partyTixTier =
          Fresh.freshPartyTixTierMap(data, false);
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
        title: AppBarTitle(title: 'checkout'),
        titleSpacing: 0,
        backgroundColor: Constants.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            // if (widget.task == 'buy') {
            //   for (String tixTierId in widget.tix.tixTierIds) {
            //     FirestoreHelper.deleteTixTier(tixTierId);
            //   }
            //   FirestoreHelper.deleteTix(widget.tix.id);
            //   Logx.d(_TAG, 'tix deleted from firebase');
            // }

            // if (kIsWeb) {
            //   GoRouter.of(context).pushNamed(RouteConstants.eventRouteName,
            //       params: {
            //         'partyName': mParty.name,
            //         'partyChapter': mParty.chapter
            //       });
            // } else {
              Navigator.of(context).pop();
            // }
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading && _isPartyTixTiersLoading
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
            _loadTixTiers(context),

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
            child: _showTixPriceProceed(context, 0)

            // _loadTixTiers(context)
        ),
      ],
    );
  }

  _showTixPriceProceed(BuildContext context, double price) {
    return Container(
      color: Constants.primary,
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'total  \u20B9 ${price.toStringAsFixed(0)}',
          ),
          DarkButtonWidget(
            text: 'proceed',
            onClicked: () {
              Logx.ist(_TAG, 'clicked proceed');
            },)
        ],
      ),
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

  // _showTixTiers(BuildContext context) {
  //   if (widget.tixTiers.isNotEmpty) {
  //     return SizedBox(
  //       child: ListView.builder(
  //           padding: EdgeInsets.zero,
  //           shrinkWrap: true,
  //           itemCount: widget.tixTiers.length,
  //           scrollDirection: Axis.vertical,
  //           itemBuilder: (ctx, index) {
  //             TixTier tixTier = widget.tixTiers[index];
  //
  //             return TixTierItem(
  //               tixTier: tixTier,
  //             );
  //           }),
  //     );
  //
  //
  //     // FirestoreHelper.pullTixTiers(widget.tix.partyId).then((res) {
  //     //   if (res.docs.isNotEmpty) {
  //     //     List<TixTier> tixTiers = [];
  //     //     for (int i = 0; i < res.docs.length; i++) {
  //     //       DocumentSnapshot document = res.docs[i];
  //     //       Map<String, dynamic> data =
  //     //       document.data()! as Map<String, dynamic>;
  //     //       final TixTier tixTier = Fresh.freshTixTierMap(data, false);
  //     //
  //     //       if (widget.tix.tixTierIds.contains(tixTier.id)) {
  //     //         tixTiers.add(tixTier);
  //     //       }
  //     //     }
  //     //
  //     //     return SizedBox(
  //     //       child: ListView.builder(
  //     //           padding: EdgeInsets.zero,
  //     //           shrinkWrap: true,
  //     //           itemCount: tixTiers.length,
  //     //           scrollDirection: Axis.vertical,
  //     //           itemBuilder: (ctx, index) {
  //     //             TixTier tixTier = tixTiers[index];
  //     //
  //     //             return TixTierItem(
  //     //               tixTier: tixTier,
  //     //             );
  //     //           }),
  //     //     );
  //     //   } else {
  //     //     Logx.em(_TAG, 'no tix tiers found for ${widget.tix.partyId}');
  //     //   }
  //     // });
  //   } else {
  //     return const Center(
  //         child: Text(
  //           'no tickets selected!',
  //           style: TextStyle(color: Constants.primary),
  //         ));
  //   }
  // }

  _loadTixTiers(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getTixTiers(widget.tix.id),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                if (snapshot.data!.docs.isNotEmpty) {
                  List<TixTier> tixTiers = [];
                  double price = 0;

                  try {
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot document = snapshot.data!.docs[i];
                      Map<String, dynamic> map =
                      document.data()! as Map<String, dynamic>;
                      final TixTier tixTier = Fresh.freshTixTierMap(map, false);
                      tixTiers.add(tixTier);

                      price += tixTier.tixTierCount * tixTier.tixTierPrice;
                    }
                    return _showTixTiers(context, tixTiers);

                    // return _showTixPriceProceed(context, price);
                  } on Exception catch (e, s) {
                    Logx.e(_TAG, e, s);
                  } catch (e) {
                    Logx.em(_TAG, 'error loading tixs : $e');
                  }
                } else {
                  return _showTixTiers(context, []);
                }
              }
          }
          return const LoadingWidget();
        });
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
