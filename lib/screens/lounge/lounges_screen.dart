import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/main.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/lounge.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/lounge/lounge_item.dart';
import '../../widgets/ui/toaster.dart';

class LoungesScreen extends StatelessWidget {

  static const String _TAG = 'LoungesScreen';
  var isLoungesLoading = true;

  List<Lounge> mLounges = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Constants.background,
        body: StreamBuilder<QuerySnapshot>(
            stream: FirestoreHelper.getLounges(),
            builder: (ctx, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const LoadingWidget();
                case ConnectionState.active:
                case ConnectionState.done:
                  {
                    List<Lounge> lounges = [];

                    try {
                      for (int i = 0; i < snapshot.data!.docs.length; i++) {
                        DocumentSnapshot document = snapshot.data!.docs[i];
                        Map<String, dynamic> map =
                            document.data()! as Map<String, dynamic>;
                        final Lounge lounge = Fresh.freshLoungeMap(map, false);
                        lounges.add(lounge);
                      }
                      return ListView.builder(
                          itemCount: lounges.length,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (ctx, index) {
                            Lounge lounge = lounges[index];

                            return GestureDetector(
                                child: LoungeItem(
                                  lounge: lounge,
                                    key: ValueKey(lounge.id)
                                ),
                                onTap: () {
                                  if(UserPreferences.isUserLoggedIn()){
                                    GoRouter.of(context).pushNamed(
                                        RouteConstants.loungeRouteName,
                                        params: {
                                          'id': lounge.id,
                                        });
                                  } else {
                                    if(!kIsWeb){
                                      Toaster.shortToast('please log in to access community');
                                    } else {
                                      Toaster.shortToast('log in to the bloc app to access community');
                                    }
                                  }
                                });
                          });
                    } on Exception catch (e, s) {
                      Logx.e(_TAG, e, s);
                    } catch (e) {
                      Logx.em(_TAG, 'error loading lounges : $e');
                    }
                  }
              }
              return const LoadingWidget();
            }));
  }
}
