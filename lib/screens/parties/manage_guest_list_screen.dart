import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/parties/party_guest_add_edit_manage_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../helpers/fresh.dart';
import '../../utils/file_utils.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logx.dart';
import '../../widgets/parties/party_guest_item.dart';
import '../../widgets/ui/loading_widget.dart';

class ManageGuestListScreen extends StatefulWidget {
  @override
  State<ManageGuestListScreen> createState() => _ManageGuestListScreenState();
}

class _ManageGuestListScreenState extends State<ManageGuestListScreen> {
  static const String _TAG = 'ManageGuestListScreen';

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
              const SizedBox(height: 5.0),
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
                      if (party.name == sPartyName) {
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

              String guestListText = '';

              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                final PartyGuest partyGuest =
                    Fresh.freshPartyGuestMap(map, false);

                //check if the guest request is more than a day old
                int timeNow = Timestamp.now().millisecondsSinceEpoch;
                int partyEndTime = 0;
                int partyStartTime = 0;
                for (Party party in mParties) {
                  if (partyGuest.partyId == party.id) {
                    partyEndTime = party.endTime;
                    partyStartTime = party.startTime;

                    break;
                  }
                }

                if (timeNow > partyEndTime + DateTimeUtils.millisecondsWeek) {
                  FirestoreHelper.deletePartyGuest(partyGuest);
                } else {
                  if(sPartyName!='all'){
                    guestListText += '${partyGuest.name},${partyGuest.surname},+${partyGuest.phone},${partyGuest.email},${partyGuest.gender}\n';
                  }

                  partyGuestList.add(partyGuest);
                }

                if (i == snapshot.data!.docs.length - 1) {
                  if(guestListText.isNotEmpty){
                    String date = DateTimeUtils.getFormattedDateYear(partyStartTime);
                    String fileName = '$sPartyName-$date.txt';
                    FileUtils.write(fileName, guestListText);
                    Logx.i(_TAG, 'saved to guest list file : $fileName');
                  }

                  return _displayGuestList(context, partyGuestList);
                }
              }
            } on Exception catch (e, s) {
              Logx.e(_TAG, e, s);
            } catch (e) {
              Logx.em(_TAG, 'error loading party guest' + e.toString());
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
                      builder: (ctx) => PartyGuestAddEditManagePage(
                            partyGuest: sPartyGuest,
                            party: sParty,
                            task: 'manage',
                          )));
                });
          }),
    );
  }
}