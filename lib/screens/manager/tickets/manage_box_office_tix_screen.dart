import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../db/entity/party.dart';
import '../../../db/entity/tix.dart';
import '../../../db/entity/tix_tier_item.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/fresh.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/tix/confirm_tix_tier_item.dart';
import '../../../widgets/tix/tix_party_banner.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class ManageBoxOfficeTixScreen extends StatefulWidget {
  String tixId;

  ManageBoxOfficeTixScreen({Key? key, required this.tixId}) : super(key: key);

  @override
  State<ManageBoxOfficeTixScreen> createState() => _ManageBoxOfficeTixScreenState();
}

class _ManageBoxOfficeTixScreenState extends State<ManageBoxOfficeTixScreen> {
  static const String _TAG = 'ManageBoxOfficeTixScreen';

  Tix mTix = Dummy.getDummyTix();
  var _isTixLoading = true;

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  late Party mParty;
  var _isPartyLoading = true;

  int totalTixCount = 0;

  @override
  void initState() {
    FirestoreHelper.pullTix(widget.tixId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mTix = Fresh.freshTixMap(data, false);

        setState(() {
          _isTixLoading = false;
        });

        FirestoreHelper.pullParty(mTix.partyId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;
            mParty = Fresh.freshPartyMap(data, false);

            setState(() {
              _isPartyLoading = false;
            });
          } else {
            Logx.est(_TAG, 'unfortunately, party could not be found!');
            setState(() {
              _isPartyLoading = false;
            });
          }
        });

      } else {
        Logx.ilt(_TAG, 'unfortunately, the ticket could not be found!');
        GoRouter.of(context).pushNamed(RouteConstants.boxOfficeRouteName);
        setState(() {
          _isTixLoading = false;
          _isPartyLoading = false;
        });
      }
    });

    FirestoreHelper.pullTixTiersByTixId(widget.tixId).then((res) {
      if (res.docs.isNotEmpty) {

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
          mTixTiers.add(tixTier);

          totalTixCount += tixTier.tixTierCount;
        }

        setState(() {
          _isTixTiersLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no tix tiers found for tix id ${widget.tixId}');

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
      appBar: AppBar(
        title: AppBarTitle(title: 'manage tix'),
        titleSpacing: 0,
      ),
      body: _isTixLoading && _isTixTiersLoading && _isPartyLoading
          ? const LoadingWidget()
          : _buildBody(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildBody(BuildContext context) {
    return _isPartyLoading
        ? const LoadingWidget()
        : ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        TixPartyBanner(
          tix: mTix,
          tixsCount: totalTixCount,
          party: mParty,
          shouldShowButton: false,
        ),
        const SizedBox(height: 24),
        _showTixTiers(context, mTixTiers),

        const Divider(),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'IGST',
              ),
              Text('\u20B9 ${mTix.igst.toStringAsFixed(2)}')
            ],
          ),
        ),
        // const Divider(),
        Container(
          color: Constants.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'sub-total',
              ),
              Text('\u20B9 ${mTix.subTotal.toStringAsFixed(2)}')
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
                'booking fee',
              ),
              Text('\u20B9 ${mTix.bookingFee.toStringAsFixed(2)}')
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
                'grand total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\u20B9 ${mTix.total.toStringAsFixed(2)}',
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),

        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonWidget(
                height: 50,
                text: '🆗 update tix',
                onClicked: () {
                  FirestoreHelper.pushTix(mTix);
                  Navigator.of(context).pop();
                },
              ),
              ButtonWidget(
                height: 50,
                text: '✅ confirm all',
                onClicked: () {
                  FirestoreHelper.pullTixTiersByTixId(widget.tixId).then((res) {
                    if (res.docs.isNotEmpty) {
                      for (int i = 0; i < res.docs.length; i++) {
                        DocumentSnapshot document = res.docs[i];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        TixTier tixTier = Fresh.freshTixTierMap(data, false);
                        tixTier = tixTier.copyWith(guestsRemaining: 0);
                        FirestoreHelper.pushTixTier(tixTier);
                      }
                    } else {
                      Logx.em(_TAG, 'no tix tiers found for tix id ${widget.tixId}');
                    }
                  });

                  mTix = mTix.copyWith(isArrived: true);

                  FirestoreHelper.pushTix(mTix);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: TextFieldWidget(
            label: 'result',
            text: mTix.result,
            maxLines: 3,
            onChanged: (text) {},
          ),
        ),

        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DarkButtonWidget(text: '🛑 delete',
              height: 50,
              onClicked: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Constants.lightPrimary,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    contentPadding: const EdgeInsets.all(16.0),
                    title: const Text(
                      '📛 confirm delete tix',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                    content: const Text(
                        "deleted tix cannot be recovered, are you sure you want to delete?"),
                    actions: [
                      TextButton(
                        child: const Text("yes"),
                        onPressed: () {
                          for(TixTier tixTier in mTixTiers){
                            FirestoreHelper.deleteTixTier(tixTier.id);
                          }
                          FirestoreHelper.deleteTix(mTix.id);
                          Logx.ist(_TAG, 'successfully deleted tix');

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Constants.darkPrimary), // Set your desired background color
                        ),
                        child: const Text("no"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },),
          ],
        ),
        const SizedBox(height: 36),
      ],
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

            return ConfirmTixTierItem(
                tixTier: tixTier,
                isUser: false
            );
          }),
    );
  }

}
