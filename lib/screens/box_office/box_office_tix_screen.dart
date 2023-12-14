import 'dart:typed_data';

import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../db/entity/tix_tier_item.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../widgets/footer.dart';
import '../../widgets/tix/confirm_tix_tier_item.dart';
import '../../widgets/tix/tix_party_banner.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/button_widget.dart';

class BoxOfficeTixScreen extends StatefulWidget {
  String tixId;

  BoxOfficeTixScreen({Key? key, required this.tixId}) : super(key: key);

  @override
  State<BoxOfficeTixScreen> createState() => _BoxOfficeTixScreenState();
}

class _BoxOfficeTixScreenState extends State<BoxOfficeTixScreen> {
  static const String _TAG = 'BoxOfficeTixScreen';

  Tix mTix = Dummy.getDummyTix();
  var _isTixLoading = true;

  List<TixTier> mTixTiers = [];
  var _isTixTiersLoading = true;

  late Party mParty;
  var _isPartyLoading = true;

  int totalTixCount = 0;

  final ScreenshotController screenshotController = ScreenshotController();

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
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'ticket'),
        titleSpacing: 0,
      ),
      backgroundColor: Constants.darkPrimary,
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
        : Screenshot(
      controller: screenshotController,
          child: ListView(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonWidget(
                        height: 50,
                        text: '🔰 share tix',
                        onClicked: () {
                          _screenCaptureToImage(context);
                          // Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Footer(),
              ],
            ),
        );
  }

  Future<void> _screenCaptureToImage(BuildContext context) async {
    screenshotController
        .capture(delay: Duration(milliseconds: 10))
        .then((capturedImage) async {
          String fileName = 'tix_${mParty.name.trim()}_${mTix.userName.trim()}.pdf';

          FileUtils.saveScreenshot(capturedImage, fileName);
          // ShowCapturedWidget(context, capturedImage!);
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage)),
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

            return ConfirmTixTierItem(
              tixTier: tixTier,
              isUser: true
            );
          }),
    );
  }
}
