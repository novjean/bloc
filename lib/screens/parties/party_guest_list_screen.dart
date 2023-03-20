import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../helpers/fresh.dart';
import '../../widgets/parties/party_guest_item.dart';
import '../../widgets/ui/loading_widget.dart';

class PartyGuestListScreen extends StatefulWidget{

  @override
  State<PartyGuestListScreen> createState() => _PartyGuestListScreenState();
}

class _PartyGuestListScreenState extends State<PartyGuestListScreen> {
  var _isPartiesLoading = true;
  List<Party> mParties = [];

  String sPartyName = 'all';
  String sPartyId = '';
  List<String> mPartyNames = [];

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullPartiesByEndTime(timeNow, true).then((res) {
      print("successfully pulled in parties");

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        List<String> _partyNames = ['all'];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          parties.add(party);
          _partyNames.add(party.name);

          setState(() {
            mParties = parties;
            mPartyNames = _partyNames;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('manage | guest list')),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _isPartiesLoading ? const SizedBox() : _displayPartiesDropdown(context),
        // _displayOptions(context),
        // const Divider(),
        const SizedBox(height: 5.0),
        _buildPartyGuestList(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _displayPartiesDropdown(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('parties_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontSize: 16.0),
                hintText: 'please select party',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide:
                  BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 0.0),
                )),
            isEmpty: sPartyName == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: TextStyle(color: Theme.of(context).primaryColor),
                dropdownColor: Theme.of(context).backgroundColor,
                value: sPartyName,
                isDense: true,
                onChanged: (String? newValue) {
                  setState(() {
                    sPartyName = newValue!;

                    for(Party party in mParties){
                      if(party.name == sPartyName){
                        sPartyId = party.id;
                        break;
                      }
                    }

                    state.didChange(newValue);
                  });
                },
                items: mPartyNames.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildPartyGuestList(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
        stream: sPartyName=='all'? FirestoreHelper.getGuestLists() : FirestoreHelper.getPartyGuestList(sPartyId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
           }

          List<PartyGuest> partyGuestList = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final PartyGuest partyGuest = PartyGuest.fromMap(map);
            // Fresh.freshPartyGuestMap(map, false);
            partyGuestList.add(partyGuest);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayGuestList(context, partyGuestList);
            }
          }
          return const LoadingWidget();
        });
  }

  _displayGuestList(BuildContext context, List<PartyGuest> partyGuestList) {
    return Expanded(
      child: ListView.builder(
          itemCount: partyGuestList.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: PartyGuestItem(
                  partyGuest: partyGuestList[index],
                ),
                // onDoubleTap: () {
                //   User sUser = users[index];
                //   logger.d('double tap user selected : ' + sUser.name);
                //
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Text("delete user : " + sUser.name),
                //         content:
                //         const Text("would you like to delete the user?"),
                //         actions: [
                //           TextButton(
                //             child: const Text("yes"),
                //             onPressed: () {
                //               FirestorageHelper.deleteFile(sUser.imageUrl);
                //               FirestoreHelper.deleteUser(sUser);
                //
                //               print('user is deleted');
                //
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //           TextButton(
                //             child: const Text("no"),
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //           )
                //         ],
                //       );
                //     },
                //   );
                // },
                // onTap: () {
                //   User sUser = users[index];
                //   logger.d('user selected : ' + sUser.name);
                //
                //   Navigator.of(context).push(MaterialPageRoute(
                //       builder: (ctx) => UserAddEditScreen(
                //         user: sUser,
                //         task: 'edit',
                //         userLevels: mUserLevels,
                //       )));
                // }
                );
          }),
    );
  }

}