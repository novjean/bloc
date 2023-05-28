
import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/parties/party_guest_add_edit_manage_screen.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_guest_item.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/toaster.dart';

class ManageGuestListScreen extends StatefulWidget {
  @override
  State<ManageGuestListScreen> createState() => _ManageGuestListScreenState();
}

class _ManageGuestListScreenState extends State<ManageGuestListScreen> {
  static const String _TAG = 'ManageGuestListScreen';

  var _isPartiesLoading = true;
  List<Party> mParties = [];

  Party sParty = Dummy.getDummyParty('');
  String sPartyName = 'all';
  String sPartyId = '';
  List<String> mPartyNames = [];

  List<PartyGuest> mPartyGuests = [];

  @override
  void initState() {
    int timeNow = Timestamp.now().millisecondsSinceEpoch;

    FirestoreHelper.pullActiveGuestListParties(timeNow).then((res) {
      Logx.i(_TAG, "successfully pulled in parties");

      if (res.docs.isNotEmpty) {
        // found parties
        List<Party> parties = [];
        List<String> _partyNames = ['all'];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, true);
          parties.add(party);
          _partyNames.add('${party.name} ${party.chapter}');
        }
        setState(() {
          mParties = parties;
          mPartyNames = _partyNames;
          _isPartiesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no parties found!');
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showActionsDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'actions',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.science,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isPartiesLoading
        ? const LoadingWidget()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 5.0),
              _displayPartiesDropdown(context),
              // _displayOptions(context),
              // const Divider(),
              const SizedBox(height: 5.0),
              _buildPartyGuestList(context),
              const SizedBox(height: 70.0),
            ],
          );
  }

  _displayPartiesDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('parties_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: TextStyle(
                    color: Theme.of(context).errorColor, fontSize: 16.0),
                hintText: 'please select party',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 0.0),
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

                    for (Party party in mParties) {
                      if (party.name + ' ' + party.chapter == sPartyName) {
                        sPartyId = party.id;
                        sParty = party;
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

  _buildPartyGuestList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: sPartyName == 'all'
            ? FirestoreHelper.getGuestLists()
            : FirestoreHelper.getPartyGuestList(sPartyId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<PartyGuest> partyGuestList = [];

          if (snapshot.data!.docs.isNotEmpty) {
            try {

              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                final PartyGuest partyGuest =
                    Fresh.freshPartyGuestMap(map, false);
                partyGuestList.add(partyGuest);

                if (i == snapshot.data!.docs.length - 1) {
                  mPartyGuests = partyGuestList;
                  return _displayGuestList(context, partyGuestList);
                }
              }
            } on Exception catch (e, s) {
              Logx.e(_TAG, e, s);
            } catch (e) {
              Logx.em(_TAG, 'error loading party guest$e');
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
            PartyGuest partyGuest = partyGuestList[index];

            String partyName = '';
            if(sPartyName == 'all'){
              for(Party party in mParties){
                if(partyGuest.partyId == party.id){
                  partyName = party.name;
                  break;
                }
              }
            } else {
              partyName = sParty.name;
            }

            return GestureDetector(
                child: PartyGuestItem(
                  partyGuest: partyGuestList[index],
                  partyName: partyName,
                ),
                onTap: () {
                  PartyGuest sPartyGuest = partyGuestList[index];

                  Party sParty = Dummy.getDummyParty('');

                  for (Party party in mParties) {
                    if (party.id == sPartyGuest.partyId) {
                      sParty = party;
                      break;
                    }
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => PartyGuestAddEditManageScreen(
                            partyGuest: sPartyGuest,
                            party: sParty,
                            task: 'manage',
                          )));
                });
          }),
    );
  }

  showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          'actions',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('in-house list'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();

                                        String guestListText = '';
                                        for(PartyGuest partyGuest in mPartyGuests){
                                          guestListText += '${partyGuest.name},${partyGuest.surname},'
                                              '+${partyGuest.phone},${partyGuest.email},${partyGuest.guestsCount} pax,${partyGuest.gender},'
                                              '${partyGuest.guestStatus},${partyGuest.isApproved?'approved':'not approved'}\n';
                                        }

                                        String rand = StringUtils.getRandomString(5);
                                        String fileName = '$sPartyName-$rand.csv';
                                        FileUtils.shareCsvFile(fileName, guestListText, sPartyName);
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('promoter list'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        Navigator.of(ctx).pop();

                                        String guestListText = '';
                                        for(PartyGuest partyGuest in mPartyGuests){
                                          guestListText += '${partyGuest.name},${partyGuest.surname},'
                                              '+${partyGuest.phone},${partyGuest.guestsCount} pax,'
                                              '${partyGuest.guestStatus},${partyGuest.isApproved?'approved':'not approved'}\n';
                                        }

                                        String rand = StringUtils.getRandomString(5);
                                        String fileName = '$sPartyName-$rand.csv';
                                        FileUtils.shareCsvFile(fileName, guestListText, sPartyName);
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('delete list'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();

                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('delete all ${sPartyName=='all'?'':sPartyName} guest lists'),
                                                content: Text('deleting ${mPartyGuests.length} guest list requests. are you sure you want to continue?'),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('yes'),
                                                    onPressed: () async {
                                                      for(PartyGuest partyGuest in mPartyGuests){
                                                        FirestoreHelper.deletePartyGuest(partyGuest);
                                                      }
                                                      Logx.i(_TAG, 'deleted all ${sPartyName=='all'?'':sPartyName} guest list requests!');
                                                      Toaster.shortToast('deleted all ${sPartyName=='all'?'':sPartyName} guest list requests!');
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text("no"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const <Widget>[
                                          Icon(Icons.delete_forever),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
