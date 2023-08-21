import 'package:bloc/db/entity/party_guest.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/parties/party_guest_add_edit_manage_screen.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

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
  List<Party> sParties = [];

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
      appBar: AppBar(
        title: AppBarTitle(title: 'manage guest list'),
        titleSpacing: 0,
      ),
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
                errorStyle: const TextStyle(
                    color: Constants.errorColor, fontSize: 16.0),
                hintText: 'please select party',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Constants.primary, width: 0.0),
                )),
            isEmpty: sPartyName == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Constants.primary),
                dropdownColor: Constants.background,
                value: sPartyName,
                isDense: true,
                onChanged: (String? newValue) {
                  setState(() {
                    sPartyName = newValue!;

                    for (Party party in mParties) {
                      if ('${party.name} ${party.chapter}' == sPartyName) {
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
            if (sPartyName == 'all') {
              for (Party party in mParties) {
                if (partyGuest.partyId == party.id) {
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                              const Text('internal list'),
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
                                        for (PartyGuest partyGuest
                                            in mPartyGuests) {
                                          String guests = '';
                                          if (partyGuest
                                              .guestNames.isNotEmpty) {
                                            for (String name
                                                in partyGuest.guestNames) {
                                              guests += '$name\n';
                                            }
                                          }

                                          guestListText +=
                                              '${partyGuest.name},${partyGuest.surname},'
                                              '+${partyGuest.phone},${partyGuest.email},${partyGuest.guestsCount} pax,${partyGuest.gender},'
                                              '${partyGuest.guestStatus},$guests,${partyGuest.isApproved ? 'approved' : 'not approved'}\n';
                                        }

                                        String rand =
                                            StringUtils.getRandomString(5);
                                        String fileName =
                                            '$sPartyName-$rand.csv';
                                        FileUtils.shareCsvFile(fileName,
                                            guestListText, sPartyName);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('share list'),
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
                                        for (PartyGuest partyGuest
                                            in mPartyGuests) {
                                          String guests = '';
                                          if (partyGuest
                                              .guestNames.isNotEmpty) {
                                            for (String name
                                                in partyGuest.guestNames) {
                                              guests += '$name\n';
                                            }
                                          }

                                          guestListText +=
                                              '${partyGuest.name},${partyGuest.surname},'
                                              '+${partyGuest.phone},${partyGuest.guestsCount} pax,'
                                              '${partyGuest.guestStatus},$guests,${partyGuest.isApproved ? 'approved' : 'not approved'}\n';
                                        }

                                        String rand =
                                            StringUtils.getRandomString(5);
                                        String fileName =
                                            '$sPartyName-$rand.csv';
                                        FileUtils.shareCsvFile(fileName,
                                            guestListText, sPartyName);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('no promoter list'),
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
                                        for (PartyGuest partyGuest
                                            in mPartyGuests) {
                                          if (partyGuest.guestStatus !=
                                              'promoter') {
                                            String guests = '';
                                            if (partyGuest
                                                .guestNames.isNotEmpty) {
                                              for (String name
                                                  in partyGuest.guestNames) {
                                                guests += '$name\n';
                                              }
                                            }

                                            guestListText +=
                                                '${partyGuest.name},${partyGuest.surname},'
                                                '+${partyGuest.phone},${partyGuest.guestsCount} pax,'
                                                '${partyGuest.guestStatus},$guests,${partyGuest.isApproved ? 'approved' : 'not approved'}\n';
                                          }
                                        }

                                        String rand =
                                            StringUtils.getRandomString(5);
                                        String fileName =
                                            '$sPartyName-$rand.csv';
                                        FileUtils.shareCsvFile(fileName,
                                            guestListText, sPartyName);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('move list'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        Navigator.of(ctx).pop();
                                        _showMoveGuestList(context);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.multiple_stop),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('delete list'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.darkPrimary,
                                    child: InkWell(
                                      splashColor: Constants.primary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        _showDeleteAllGuestList(context);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
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

  _showDeleteAllGuestList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'delete all ${sPartyName == 'all' ? '' : sPartyName} guest lists',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'deleting ${mPartyGuests.length} guest list requests. are you sure you want to continue?'),
            actions: [
              TextButton(
                child: const Text('yes'),
                onPressed: () async {
                  for (PartyGuest partyGuest in mPartyGuests) {
                    FirestoreHelper.deletePartyGuest(partyGuest);
                  }
                  Logx.i(_TAG,
                      'deleted all ${sPartyName == 'all' ? '' : sPartyName} guest list requests!');
                  Toaster.shortToast(
                      'deleted all ${sPartyName == 'all' ? '' : sPartyName} guest list requests!');
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
  }

  _showMoveGuestList(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 100,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('select move to party'),
                  MultiSelectDialogField(
                    items: mParties
                        .map((e) => MultiSelectItem(e, '${e.name} ${e.chapter}'))
                        .toList(),
                    initialValue: sParties.map((e) => e).toList(),
                    listType: MultiSelectListType.CHIP,
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                    title: const Text('pick a party'),
                    buttonText: const Text(
                      'select',
                      style: TextStyle(color: Constants.darkPrimary),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 0.0,
                      ),
                    ),
                    searchable: true,
                    onConfirm: (values) {
                      sParties = values as List<Party>;

                      if (sParties.isNotEmpty) {
                        Party sParty = sParties.first;

                        for(PartyGuest pg in mPartyGuests){
                          pg = pg.copyWith(partyId: sParty.id);
                          FirestoreHelper.pushPartyGuest(pg);
                        }

                        Logx.ist(_TAG, 'moved ${mPartyGuests.length} guests to ${sParty.name}');
                        Navigator.of(ctx).pop();
                      } else {
                        Logx.ist(_TAG, 'move to party needs to be selected');
                      }
                    },
                  ),

                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
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
