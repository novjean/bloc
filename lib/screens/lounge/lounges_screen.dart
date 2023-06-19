import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/lounge.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/lounge_item.dart';

class LoungesScreen extends StatefulWidget {
  @override
  State<LoungesScreen> createState() => _LoungesScreenState();
}

class _LoungesScreenState extends State<LoungesScreen> {
  static const String _TAG = 'LoungesScreen';
  var isLoungesLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.background, body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        UserPreferences.isUserLoggedIn()
            ? _loadLounges(context)
            : LoadingWidget(),
      ],
    );
  }

  _loadLounges(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getLounges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          List<Lounge> lounges = [];

          if (snapshot.data!.docs.isNotEmpty) {
            try {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                final Lounge lounge = Fresh.freshLoungeMap(map, false);
                lounges.add(lounge);

                if (i == snapshot.data!.docs.length - 1) {
                  return _showLounges(context, lounges);
                }
              }
            } on Exception catch (e, s) {
              Logx.e(_TAG, e, s);
            } catch (e) {
              Logx.em(_TAG, 'error loading lounges : $e');
            }
          }

          return const LoadingWidget();
        });
  }

  _showLounges(BuildContext context, List<Lounge> lounges) {
    return Expanded(
      child: ListView.builder(
          itemCount: lounges.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Lounge lounge = lounges[index];

            return GestureDetector(
                child: LoungeItem(
                  lounge: lounge,
                ),
                onTap: () {
                  // open lounge
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (ctx) =>
                  //         CelebrationAddEditScreen(
                  //       celebration: celebration,
                  //       task: 'edit',
                  //     )));
                });
          }),
    );
  }
}
