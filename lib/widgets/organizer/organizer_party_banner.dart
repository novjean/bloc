import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc.dart';
import '../../db/entity/bloc_service.dart';
import '../../db/entity/party.dart';
import '../../db/entity/party_interest.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../screens/manager/organizers/organizer_party_add_edit_screen.dart';
import '../../screens/organizer/organizer_party_sales_screen.dart';
import '../../screens/organizer/organizer_party_tixs_screen.dart';

class OrganizerPartyBanner extends StatefulWidget {
  Party party;
  final bool shouldShowInterestCount;

  OrganizerPartyBanner(
      {Key? key,
        required this.party,
        required this.shouldShowInterestCount})
      : super(key: key);

  @override
  State<OrganizerPartyBanner> createState() => _OrganizerPartyBannerState();
}

class _OrganizerPartyBannerState extends State<OrganizerPartyBanner> {
  static const String _TAG = 'OrganizerPartyBanner';

  late BlocService mBlocService;
  var _isBlocServiceLoading = true;

  late Bloc mBloc;
  var _isBlocLoading = true;

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();

  @override
  void initState() {
    FirestoreHelper.pullBlocServiceById(widget.party.blocServiceId).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        setState(() {
          mBlocService = Fresh.freshBlocServiceMap(data, false);
          _isBlocServiceLoading = false;
        });

        FirestoreHelper.pullBlocById(mBlocService.blocId).then((res) {
          if(res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

            setState(() {
              mBloc = Fresh.freshBlocMap(data, false);
              _isBlocLoading = false;
            });
          }
        });
      }
    });

    if (widget.shouldShowInterestCount) {
      mPartyInterest.partyId = widget.party.id;

      FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
        if (res.docs.isNotEmpty) {
          DocumentSnapshot document = res.docs[0];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyInterest partyInterest =
          Fresh.freshPartyInterestMap(data, false);
          if (mounted) {
            setState(() {
              mPartyInterest = partyInterest;
            });
          }
        } else {
          // party interest does not exist
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int interestCount = mPartyInterest.initCount + mPartyInterest.userIds.length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) =>
                OrganizerPartyAddEditScreen(party: widget.party, task: 'edit')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Hero(
            tag: widget.party.id,
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
                            child: RichText(
                              maxLines: 2,
                              text: TextSpan(
                                  text: '${widget.party.name.toLowerCase()} ',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: Constants.fontDefault,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: widget.party.chapter == 'I'
                                            ? ' '
                                            : '${widget.party.chapter} ',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: Constants.fontDefault,
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.italic)),
                                  ]),
                            ),
                          ),
                          widget.party.eventName.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.only(left: 5.0, top: 5),
                            child: Text(
                              _isBlocLoading ? '': '${mBloc.addressLine1}, ${mBloc.addressLine2}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ) : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              widget.party.isTBA
                                  ? 'tba'
                                  : '${DateTimeUtils.getFormattedDate(widget.party.startTime)}, ${DateTimeUtils.getFormattedTime(widget.party.startTime)}',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          const Spacer(),
                          Text(widget.party.isPayoutComplete ? 'payout complete' : '',
                            style: const TextStyle(backgroundColor: Constants.primary),),

                          widget.shouldShowInterestCount
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5, bottom: 1),
                                child: DelayedDisplay(
                                  delay: const Duration(seconds: 1),
                                  child: Text('$interestCount 🖤',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                              : const SizedBox(),
                          _displayTicketsSalesRow()
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
                            image: NetworkImage(widget.party.imageUrl),
                            fit: BoxFit.cover,
                          )
                              : CachedNetworkImage(
                            imageUrl: widget.party.imageUrl,
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

  _displayTicketsSalesRow() {
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
                  'tickets',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(
                  Icons.star,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          OrganizerPartyTixsScreen(party: widget.party)));
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
                  'sales',
                  style: TextStyle(fontSize: 18),
                ),
                icon: const Icon(
                  Icons.money,
                  size: 24.0,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          OrganizerPartySalesScreen(party: widget.party)));
                },
              ),
            )),
      ],
    );
  }
}
