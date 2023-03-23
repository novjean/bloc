import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../helpers/fresh.dart';
import '../../widgets/parties/party_item.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../../widgets/ui/toaster.dart';
import '../box_office/box_office_screen.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({Key? key}) : super(key: key);

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  List<Party> mParties = [];
  var _isPartiesLoading = true;

  var _showPastParties = false;
  List<Party> mPastParties = [];
  var _isPastPartiesLoading = true;

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
      print("successfully pulled in parties");

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          parties.add(party);

          setState(() {
            mParties = parties;
            _isPartiesLoading = false;
          });
        }
      } else {
        print('no parties found!');
        const Center(
          child: Text('no parties assigned yet!'),
        );
        setState(() {
          _isPartiesLoading = false;
        });
      }
    });

    FirestoreHelper.pullPastParties(
            Timestamp.now().millisecondsSinceEpoch, false)
        .then((res) {
      print("successfully pulled in past parties");

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party bloc = Fresh.freshPartyMap(data, true);
          parties.add(bloc);

          setState(() {
            mPastParties = parties;
            _isPastPartiesLoading = false;
          });
        }
      } else {
        print('no past parties found!');
        const Center(
          child: Text('no past parties found yet!'),
        );
        setState(() {
          _isPastPartiesLoading = false;
        });
      }
    });
    super.initState();
  }

  _buildBody(BuildContext context) {
    List<Party> parties = [];

    parties = _showPastParties ? mPastParties : mParties;

    if (parties.isEmpty) {
      if (_showPastParties) {
        Toaster.shortToast('no upcoming parties');
        print('no upcoming parties to show');

        if (mParties.isNotEmpty) {
          parties = mParties;
        } else {
          return const Center(
            child: Text('no parties yet, check back here soon'),
          );
        }
      } else {
        Toaster.shortToast('no past parties');
        if (mPastParties.isNotEmpty) {
          parties = mPastParties;
        } else {
          return const Center(
            child: Text('no parties yet, check back here soon'),
          );
        }
      }
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: parties.length,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
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
                          print('show upcoming parties button clicked');
                          setState(() {
                            _showPastParties = !_showPastParties;
                          });
                        })
                    : const SizedBox(),
                PartyItem(
                  party: parties[index],
                  imageHeight: 300,
                ),
              ],
            );
          }
          if (index == parties.length - 1) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PartyItem(
                  party: parties[index],
                  imageHeight: 300,
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
                          print('load parties button clicked');
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
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => BoxOfficeScreen()),
            );
          },
          child: Icon(
            Icons.play_arrow_outlined,
            color: Theme.of(context).primaryColorDark,
            size: 29,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: 'box office',
          elevation: 5,
          splashColor: Colors.grey,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _isPartiesLoading ? const LoadingWidget() : _buildBody(context));
  }
}
