import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_tix_tier.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/tix_tier_item.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/box_office/promoter_tix_data_item.dart';
import '../../widgets/organizer/organizer_sales_tix_tier_item.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../box_office/promoter_box_office_tix_screen.dart';

class OrganizerPartyTixsScreen extends StatefulWidget {
  final Party party;

  const OrganizerPartyTixsScreen({super.key, required this.party});

  @override
  State<OrganizerPartyTixsScreen> createState() => _OrganizerPartyTixsScreenState();
}

class _OrganizerPartyTixsScreenState extends State<OrganizerPartyTixsScreen> {
  static const String _TAG = 'OrganizerPartyTixsScreen';

  late List<String> mOptions;
  String sOption = '';

  List<Tix> mTixs = [];
  List<PartyTixTier> mPartyTixTiers = [];
  var _isPartyTixTiersLoading = true;

  @override
  void initState() {
    mOptions = ['tickets', 'sales'];
    sOption = mOptions.first;

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
        title: AppBarTitle(title: 'tickets',),
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _loadTixsList(context)
          // _showDisplayOptions(context),
          // const Divider(color: Constants.darkPrimary),
          // sOption == mOptions.first ? _loadTixsList(context) : _displayTixSales(context),
          // const SizedBox()
        ],
      ),
    );
  }

  _showDisplayOptions(BuildContext context) {
    double containerHeight = 50;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: 50,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Constants.primary,
                ),
                onTap: () {
                  Logx.i(_TAG, '$sOption at sales is selected');
                  setState(() {
                    sOption = mOptions[index];
                  });
                });
          }),
    );
  }

  _loadTixsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getTixsSuccessfulByPartyId(widget.party.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Expanded(
                      child: Center(
                          child: Text('no tickets have been sold yet!',
                            style: TextStyle(color: Constants.primary),)));
                } else {
                  mTixs.clear();

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                    final Tix tix = Fresh.freshTixMap(map, false);
                    mTixs.add(tix);
                  }

                  return _displayTixs(context);
                }
              } else {
                return const Expanded(
                    child: Center(
                        child: Text('no tickets have been sold yet!',
                          style: TextStyle(color: Constants.primary),)));
              }
            }
        }
      },
    );
  }

  _displayTixs(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: mTixs.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PromoterBoxOfficeTixScreen(tixId: mTixs[index].id)));
            },
            child: PromoterTixDataItem(
              tix: mTixs[index],
              party: widget.party,
              isClickable: true,
            ),
          );
        },
      ),
    );
  }

  _displayTixSales(BuildContext context) {
    double total = 0;
    for(PartyTixTier partyTixTier in mPartyTixTiers){
      total += (partyTixTier.tierPrice * partyTixTier.soldCount);
    }

    return Stack(
        children:[
          SizedBox(
            child: Column(
              children: [
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: mPartyTixTiers.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (ctx, index) {
                    return OrganizerSalesTixTierItem(
                      partyTixTier: mPartyTixTiers[index],
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _showTixPricePurchase(context, total)),
        ]
    );
  }

  _displaySales(BuildContext context) {
    double total = 0;
    for(PartyTixTier partyTixTier in mPartyTixTiers){
      total += (partyTixTier.tierPrice * partyTixTier.soldCount);
    }

    if(total > 0){
      return SizedBox(
        height: mq.height*0.7,
        child: Stack(
          children: [
            _displayTixSales(context),

            // ListView(
            //   physics: const BouncingScrollPhysics(),
            //   children: [
            //     // _displayTixSales(context),
            //     const SizedBox(
            //       height:90,
            //     ),
            //   ],
            // ),
            // Floating Container at the bottom
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _showTixPricePurchase(context, total)),
          ],
        ),
      );
    } else {
      return Expanded(
          child: Center(
              child: Text('total: ${total.toStringAsFixed(2)}',
                style: TextStyle(color: Constants.primary),)));
    }
  }

  _showTixPricePurchase(BuildContext context, double total) {
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
        Container(
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
        ),
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

        // Container(
        //   color: Constants.primary,
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       UserPreferences.myUser.clearanceLevel == Constants.ADMIN_LEVEL
        //           ? Text('result :\n$result')
        //           : const SizedBox(),
        //       ElevatedButton.icon(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Constants.background,
        //           foregroundColor: Constants.primary,
        //           shadowColor: Colors.white30,
        //           elevation: 3,
        //           shape: const RoundedRectangleBorder(
        //             borderRadius: BorderRadius.all(
        //               Radius.circular(9),)
        //             ,
        //           ),
        //         ),
        //         onPressed: () {
        //           body = getChecksum().toString();
        //           _startTransaction();
        //
        //           // todo: waiting for PhonePe to fix UPI intent
        //           // // here we are gonna check what all is installed on phone
        //           // if (!UserPreferences.myUser.isIos) {
        //           //   String? apps =
        //           //       await PhonePePaymentSdk.getInstalledUpiAppsForAndroid();
        //           //
        //           //   Iterable l = json.decode(apps!);
        //           //   List<UPIApp> upiApps =
        //           //       List<UPIApp>.from(l.map((model) => UPIApp.fromJson(model)));
        //           //   String appString = '';
        //           //
        //           //   if(upiApps.isNotEmpty){
        //           //     for (var element in upiApps) {
        //           //       appString +=
        //           //       "${element.applicationName} ${element.version} ${element.packageName}";
        //           //     }
        //           //
        //           //     Logx.d(_TAG, 'installed Upi Apps - $appString');
        //           //
        //           //     _showUpiAppsBottomSheet(context, upiApps);
        //           //   } else {
        //           //     startPgTransaction();
        //           //   }
        //           // } else {
        //           //   //ios implement pending
        //           //   startPgTransaction();
        //           // }
        //         },
        //         label: const Text(
        //           'purchase',
        //           style: TextStyle(fontSize: 20, color: Constants.primary),
        //         ),
        //         icon: const Icon(
        //           Icons.local_play,
        //           size: 24.0,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

}