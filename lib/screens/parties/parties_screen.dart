import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_item.dart';
import '../../widgets/ui/sized_listview_block.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({Key? key}) : super(key: key);

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  static const String _TAG = 'PartiesScreen';

  List<Party> mParties = [];
  var _isPartiesLoading = true;

  var _showPastParties = false;
  List<Party> mPastParties = [];
  var _isPastPartiesLoading = true;

  List<PartyGuest> mPartyGuestRequests = [];
  var _isPartyGuestsLoading = true;

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullPartiesByEndTime(timeNow, true, false).then((res) {
      Logx.i(_TAG, 'successfully pulled in parties');

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);

          if(UserPreferences.getUserBlocs().contains(party.blocServiceId)){
            parties.add(party);
          }
        }

        setState(() {
          mParties = parties;
          _isPartiesLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no parties found!');
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    FirestoreHelper.pullPastParties(
            Timestamp.now().millisecondsSinceEpoch, false)
        .then((res) {
      Logx.i(_TAG, "successfully pulled in past parties");

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);

          if(UserPreferences.getUserBlocs().contains(party.blocServiceId)){
            parties.add(party);
          }
        }

        setState(() {
          mPastParties = parties;
          _isPastPartiesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no past parties found!');
        setState(() {
          _isPastPartiesLoading = false;
        });
      }
    });

    FirestoreHelper.pullGuestListRequested(UserPreferences.myUser.id)
        .then((res) {
      Logx.i(_TAG, "successfully pulled in requested guest list");

      if (res.docs.isNotEmpty) {
        // found party guests
        List<PartyGuest> partyGuestRequests = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
          partyGuestRequests.add(partyGuest);
        }
        setState(() {
          mPartyGuestRequests = partyGuestRequests;
          _isPartyGuestsLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no party guest requests found!');

        setState(() {
          _isPartyGuestsLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.background,
        floatingActionButton: UserPreferences.isUserLoggedIn()
            ? FloatingActionButton(
                onPressed: () {
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.boxOfficeRouteName);
                },
                backgroundColor: Theme.of(context).primaryColor,
                tooltip: 'box office',
                elevation: 5,
                splashColor: Colors.grey,
                child: Icon(
                  Icons.keyboard_command_key_sharp,
                  color: Constants.darkPrimary,
                  size: 29,
                ),
              )
            : const SizedBox(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _isPartiesLoading & _isPartyGuestsLoading
            ? const LoadingWidget()
            : _buildBody(context));
  }

  _buildBody(BuildContext context) {
    List<Party> parties = [];

    parties = _showPastParties ? mPastParties : mParties;

    if (parties.isEmpty) {
      if (_showPastParties) {
        if (mParties.isNotEmpty) {
          parties = mParties;
        } else {
          return const Center(
            child: Text('no parties yet, check back here soon', style: TextStyle(color: Constants.primary),),
          );
        }
      } else {
        Logx.i(_TAG, 'no past parties');
        if (mPastParties.isNotEmpty) {
          parties = mPastParties;
        } else {
          return const Center(
            child: Text('no parties yet, check back here soon', style: TextStyle(color: Constants.primary),),
          );
        }
      }
    }

    return ListView.builder(
      itemCount: parties.length,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        bool isGuestListRequested = false;

        Party party = parties[index];
        for (PartyGuest partyGuest in mPartyGuestRequests) {
          if (partyGuest.partyId == party.id) {
            isGuestListRequested = true;
            break;
          }
        }

        if (parties.length == 1) {
          if (_showPastParties) {
            return Column(
              children: [
                GestureDetector(
                    child: SizedListViewBlock(
                      title: 'show upcoming parties',
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Constants.primary,
                    ),
                    onTap: () {
                      Logx.i(_TAG, 'show upcoming parties button clicked');
                      setState(() {
                        _showPastParties = !_showPastParties;
                      });
                    }),
                PartyItem(
                  party: parties[index],
                  imageHeight: 300,
                  isGuestListRequested: isGuestListRequested,
                ),
              ],
            );
          } else {
            return Column(
              children: [
                PartyItem(
                  party: parties[index],
                  imageHeight: 300,
                  isGuestListRequested: isGuestListRequested,
                ),
                GestureDetector(
                    child: SizedListViewBlock(
                      title: 'show past parties',
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      Logx.i(_TAG, 'show upcoming parties button clicked');
                      setState(() {
                        _showPastParties = !_showPastParties;
                      });
                    }),
              ],
            );
          }
        }

        if (index == 0) {
          return Column(
            children: [
              _showPastParties
                  ? GestureDetector(
                      child: SizedListViewBlock(
                        title: 'show upcoming parties',
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        Logx.i(_TAG, 'show upcoming parties button clicked');
                        setState(() {
                          _showPastParties = !_showPastParties;
                        });
                      })
                  : const SizedBox(),
              PartyItem(
                party: parties[index],
                imageHeight: 300,
                isGuestListRequested: isGuestListRequested,
              ),
            ],
          );
        }
        if (index == parties.length - 1) {
          return Column(
            children: [
              PartyItem(
                party: parties[index],
                imageHeight: 300,
                isGuestListRequested: isGuestListRequested,
              ),
              !_showPastParties
                  ? GestureDetector(
                      child: SizedListViewBlock(
                        title: 'show past parties',
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        Logx.i(_TAG, 'load parties button clicked');
                        setState(() {
                          _showPastParties = !_showPastParties;
                        });
                      })
                  : const SizedBox()
            ],
          );
        } else {
          return PartyItem(
            party: parties[index],
            imageHeight: 300,
            isGuestListRequested: isGuestListRequested,
          );
        }
      },
    );
  }
}
