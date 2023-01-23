import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../widgets/parties/party_item.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({Key? key}) : super(key: key);

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  List<Party> mParties = [];
  var _isPartiesLoading = true;

  @override
  void initState() {
    super.initState();

    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullParties(timeNow).then((res) {
      print("Successfully pulled in parties.");

      if (res.docs.isNotEmpty) {
        // found blocs
        List<Party> parties = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party bloc = Party.fromMap(data);
          parties.add(bloc);

          setState(() {
            mParties = parties;
            _isPartiesLoading = false;
          });
        }
      } else {
        print('no parties found, Booo!');
        //todo: need to re-attempt or check internet connection
      }
    });
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 1.0,
      ),
      child: Expanded(
        child: ListView.builder(
          itemCount: mParties.length,
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: PartyItem(party: mParties[index]),
              onTap: () {
                Party _sParty = mParties[index];
                print(_sParty.name + ' is selected.');
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: _isPartiesLoading ? const SizedBox() : _buildBody(context));
  }
}
