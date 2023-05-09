import 'package:bloc/db/entity/challenge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/dummy.dart';
import '../../../../helpers/firestore_helper.dart';
import '../../../../helpers/fresh.dart';
import '../../../../utils/logx.dart';
import '../../../../widgets/ui/listview_block.dart';
import '../../../../widgets/ui/loading_widget.dart';
import 'challenge_add_edit_screen.dart';

class ManageChallengesScreen extends StatelessWidget {
  static const String _TAG = 'ManageChallengesScreen';

  ManageChallengesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('manage | challenges'),
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
        tooltip: 'add ad',
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          _buildChallenges(context),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _buildChallenges(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getChallenges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<Challenge> challenges = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Challenge challenge = Fresh.freshChallengeMap(map, false);
            challenges.add(challenge);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayChallenges(context, challenges);
            }
          }
          Logx.i(_TAG, 'loading challenges...');
          return const LoadingWidget();
        });
  }

  _displayChallenges(BuildContext context, List<Challenge> challenges) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: challenges.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: challenges[index].title,
                ),
                onTap: () {
                  Challenge sChallenge = challenges[index];
                  Logx.i(_TAG,'selected challenge ' + sChallenge.title);

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
