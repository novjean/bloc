import 'package:bloc/widgets/ui/toaster.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';
import 'party_banner.dart';

class PartyGuestAddEditPage extends StatefulWidget {
  Party party;
  String task;

  PartyGuestAddEditPage({key, required this.party, required this.task})
      : super(key: key);

  @override
  _PartyGuestAddEditPageState createState() => _PartyGuestAddEditPageState();
}

class _PartyGuestAddEditPageState extends State<PartyGuestAddEditPage> {
  late PartyGuest partyGuest;
  late blocUser.User user;

  bool isPhotoChanged = false;

  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  bool hasUserChanged = false;

  late String sGuestCount;
  List<String> guestCounts = [];

  @override
  void initState() {
    user = UserPreferences.myUser;

    partyGuest = Dummy.getDummyPartyGuest();
    partyGuest.partyId = widget.party.id;

    for (int i = 1; i <= 4; i++) {
      guestCounts.add(i.toString());
    }
    sGuestCount = guestCounts.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('party guest | ' + widget.task),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 0),
        PartyBanner(
          party: widget.party,
          isClickable: false,
          shouldShowButton: false,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: DarkTextFieldWidget(
            label: 'name \*',
            text: user.name,
            onChanged: (name) {
              user = user.copyWith(name: name);
              hasUserChanged = true;

              partyGuest = partyGuest.copyWith(name: name);
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: DarkTextFieldWidget(
              label: 'email',
              text: user.email,
              onChanged: (email) {
                user = user.copyWith(email: email);
                hasUserChanged = true;

                partyGuest = partyGuest.copyWith(email: email);
              }),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'number of guests',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('guest_count'),
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        errorStyle: TextStyle(
                            color: Theme.of(context).errorColor,
                            fontSize: 16.0),
                        hintText: 'please select guest count',
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
                    isEmpty: sGuestCount == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        style: TextStyle(color: Theme.of(context).primaryColorLight),
                        dropdownColor: Theme.of(context).backgroundColor,
                        value: sGuestCount,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            sGuestCount = newValue!;
                            int count = int.parse(sGuestCount);

                            partyGuest =
                                partyGuest.copyWith(guestsCount: count);
                            state.didChange(newValue);
                          });
                        },
                        items: guestCounts.map((String value) {
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
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ButtonWidget(
            text: 'join guest list',
            onClicked: () {
              // we should have some validation here
              if (isDataValid()) {
                if (hasUserChanged) {
                  User freshUser = Fresh.freshUser(user);
                  UserPreferences.setUser(freshUser);
                  FirestoreHelper.pushUser(freshUser);

                  PartyGuest freshPartyGuest =
                      Fresh.freshPartyGuest(partyGuest);
                  FirestoreHelper.pushPartyGuest(freshPartyGuest);
                } else {
                  PartyGuest freshPartyGuest =
                      Fresh.freshPartyGuest(partyGuest);
                  FirestoreHelper.pushPartyGuest(freshPartyGuest);
                }

                Toaster.longToast('guest list request is successfully sent');
                Navigator.of(context).pop();
              } else {
                print('user cannot be entered as data is incomplete');
              }
            },
          ),
        ),
      ],
    );
  }

  bool isDataValid() {
    if (partyGuest.name.isEmpty) {
      Toaster.longToast('please enter your name');
      return false;
    }

    return true;
  }
}
