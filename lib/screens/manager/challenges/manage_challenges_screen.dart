import 'package:bloc/db/entity/challenge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/dummy.dart';
import '../../../../helpers/firestore_helper.dart';
import '../../../../helpers/fresh.dart';
import '../../../../utils/logx.dart';
import '../../../../widgets/ui/loading_widget.dart';
import '../../../widgets/manager/manage_challenge_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import 'challenge_add_edit_screen.dart';

class ManageChallengesScreen extends StatelessWidget {
  static const String _TAG = 'ManageChallengesScreen';

  ManageChallengesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage challenges'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ChallengeAddEditScreen(
                  challenge: Dummy.getDummyChallenge(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add challenge',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _buildChallenges(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildChallenges(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getChallenges(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Challenge> challenges = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
                  final Challenge challenge = Fresh.freshChallengeMap(map, false);
                  challenges.add(challenge);
                }
                return _displayChallenges(context, challenges);
              }
          }
        });
  }

  _displayChallenges(BuildContext context, List<Challenge> challenges) {
    return Expanded(
      child: ListView.builder(
          itemCount: challenges.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageChallengeItem(
                  challenge: challenges[index],
                ),
                onTap: () {
                  Challenge sChallenge = challenges[index];
                  Logx.i(_TAG,'selected challenge ${sChallenge.title}');

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => ChallengeAddEditScreen(
                          challenge: sChallenge,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
