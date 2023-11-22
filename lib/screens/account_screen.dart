import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/user.dart' as blocUser;
import '../db/entity/friend.dart';
import '../db/entity/history_music.dart';
import '../db/entity/party_guest.dart';
import '../db/entity/reservation.dart';
import '../db/entity/user_lounge.dart';
import '../db/shared_preferences/table_preferences.dart';
import '../helpers/firestorage_helper.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../routes/route_constants.dart';

import '../utils/constants.dart';
import '../utils/logx.dart';
import '../widgets/footer.dart';
import '../widgets/ui/sized_listview_block.dart';

class AccountScreen extends StatelessWidget {
  static const String _TAG = 'AccountScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(
          title: 'account',
        ),
        titleSpacing: 0,
      ),
      backgroundColor: Constants.background,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'privacy policy',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Constants.primary,
            ),
            onTap: () {
              GoRouter.of(context).pushNamed(RouteConstants.privacyRouteName);
            }),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'delivery policy',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Constants.primary,
            ),
            onTap: () {
              GoRouter.of(context).pushNamed(RouteConstants.deliveryRouteName);
            }),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'refund policy',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Constants.primary,
            ),
            onTap: () {
              GoRouter.of(context).pushNamed(RouteConstants.refundRouteName);
            }),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'terms and conditions',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Constants.primary,
            ),
            onTap: () {
              GoRouter.of(context).pushNamed(RouteConstants.termsAndConditionsRouteName);
            }),
        const Divider(),
        UserPreferences.myUser.clearanceLevel>=Constants.PROMOTER_LEVEL?
        GestureDetector(
            child: SizedListViewBlock(
              title: 'checkout screen',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Constants.primary,
            ),
            onTap: () {
              GoRouter.of(context).pushNamed(RouteConstants.checkoutRouteName);
            }) : const SizedBox(),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'delete account',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Constants.errorColor,
            ),
            onTap: () {
              if (UserPreferences.isUserLoggedIn()) {
                _showDeleteAccountDialog(context);
              } else {
                _showLoginDialog(context);
              }
            }),
        const Divider(),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            'v ${Constants.appVersion}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Constants.primary),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top:15.0, bottom: 5, left: 10, right: 10),
          child: Text('Copyright Novatech Corp 2023. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Constants.primary, fontSize: 12),),
        )      ],
    );
  }

  _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            '📛 delete account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: const Text(
              "listen up: if you take that leap and say goodbye, all your data and music history vanish into the void – no coming back, no rewind. are you sure you want to delete?"),
          actions: [
            TextButton(
              child: const Text("yes"),
              onPressed: () async {
                blocUser.User sUser = UserPreferences.myUser;

                if (sUser.imageUrl.isNotEmpty) {
                  if(sUser.imageUrl.contains(FirestorageHelper.USER_IMAGES)){
                    await FirestorageHelper.deleteFile(sUser.imageUrl);
                  } else {
                    // profile photo from party photos
                  }
                }

                // delete all friend connections
                FirestoreHelper.pullFriendConnections(sUser.id).then((res) {
                  if(res.docs.isNotEmpty){
                    for(int i=0;i<res.docs.length; i++){
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      Friend friend = Fresh.freshFriendMap(data, false);
                      FirestoreHelper.deleteFriend(friend.id);
                    }
                  }
                });

                FirestoreHelper.pullPartyGuestsByUser(sUser.id).then((res) {
                  if(res.docs.isNotEmpty){
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
                      FirestoreHelper.deletePartyGuest(partyGuest.id);
                    }
                    Logx.i(_TAG, '${sUser.name} ${sUser.surname}\'s ${res.docs.length} guest list requests deleted');
                  }
                });

                FirestoreHelper.pullReservationsByUser(sUser.id).then((res) {
                  if(res.docs.isNotEmpty){
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final Reservation reservation = Fresh.freshReservationMap(data, false);
                      FirestoreHelper.deleteReservation(reservation.id);
                    }
                    Logx.i(_TAG, '${sUser.name} ${sUser.surname}\'s ${res.docs.length} reservations deleted');
                  }
                });

                FirestoreHelper.pullHistoryMusicByUser(sUser.id).then((res) {
                  if(res.docs.isNotEmpty){
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final HistoryMusic historyMusic = Fresh.freshHistoryMusicMap(data, false);
                      FirestoreHelper.deleteHistoryMusic(historyMusic.id);
                    }
                  }
                  Logx.i(_TAG, '${sUser.name} ${sUser.surname}\'s ${res.docs.length} music history deleted');
                });

                FirestoreHelper.pullUserLounges(sUser.id).then((res) {
                  if(res.docs.isNotEmpty){
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);

                      FirestoreHelper.deleteUserLounge(userLounge.id);
                    }
                    Logx.i(_TAG, '${sUser.name} ${sUser.surname} is removed from ${res.docs.length} lounges');
                  }
                });

                FirestoreHelper.deleteUser(sUser.id);
                UserPreferences.resetUser();
                TablePreferences.resetQuickTable();

                Logx.i(_TAG, 'user account is deleted');

                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  user!.delete();
                } on PlatformException catch (e, s) {
                  Logx.e(_TAG, e, s);
                } on Exception catch (e, s) {
                  Logx.e(_TAG, e, s);
                } catch (e) {
                  Logx.em(_TAG, 'account delete failed $e');
                }

                await FirebaseAuth.instance.signOut();

                GoRouter.of(context)
                    .pushNamed(RouteConstants.loginRouteName, params: {
                  'skip': 'false',
                });
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
  }

  _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            '🪵 login required',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: const Text(
              "hold up, before you wave goodbye, let's link up – login's the move before we part ways with your account!. would you like to login?"),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                GoRouter.of(context)
                    .pushNamed(RouteConstants.loginRouteName, params: {
                  'skip': 'false',
                });
              },
              child: const Text("yes"),
            ),
            TextButton(
              child: const Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
