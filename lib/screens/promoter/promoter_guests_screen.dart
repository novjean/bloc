import 'package:bloc/db/entity/promoter_guest.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/screens/manager/promoters/manage_guests_created_screen.dart';
import 'package:bloc/utils/scan_utils.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';
import '../../db/entity/party_interest.dart';
import '../../db/entity/promoter.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/box_office/promoter_box_office_item.dart';
import '../../widgets/parties/party_guest_widget.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/dark_button_widget.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../../widgets/ui/textfield_widget.dart';
import '../manager/promoters/promoter_add_edit_screen.dart';

class PromoterGuestsScreen extends StatefulWidget {
  final Party party;

  const PromoterGuestsScreen({Key? key, required this.party}) : super(key: key);

  @override
  State<PromoterGuestsScreen> createState() => _PromoterGuestsScreenState();
}

class _PromoterGuestsScreenState extends State<PromoterGuestsScreen> {
  static const String _TAG = 'PromoterGuestsScreen';

  bool testMode = true;

  late List<String> mOptions;
  late String sOption;

  List<Promoter> mPromoters = [];
  List<String> mPromoterNames = [];
  late String sPromoterName;
  late String sPromoterId;
  var _isPromotersLoading = true;

  List<PartyGuest> mPartyGuests = [];
  List<PartyGuest> searchList = [];
  bool isSearching = false;

  String mLines = '';
  late TextEditingController controller;

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();
  bool _isPartyInterestLoading = true;

  @override
  void initState() {
    controller = TextEditingController();

    mOptions = ['arriving', 'completed', 'unapproved', 'add'];
    sOption = mOptions.first;

    sPromoterName = 'bloc';
    sPromoterId = Constants.blocPromoterId;

    FirestoreHelper.pullPromoters().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          Promoter promoter = Fresh.freshPromoterMap(data, false);
          mPromoters.add(promoter);
          mPromoterNames.add(promoter.name);
        }
        setState(() {
          _isPromotersLoading = false;
        });
      } else {
        setState(() {
          _isPromotersLoading = false;
        });
      }
    });

    FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mPartyInterest = Fresh.freshPartyInterestMap(data, false);
        setState(() {
          _isPartyInterestLoading = false;
        });
      } else {
        setState(() {
          _isPartyInterestLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(
          title:
              '${widget.party.name} ${widget.party.chapter == 'I' ? '' : widget.party.chapter}',
        ),
        titleSpacing: 0,
      ),
      floatingActionButton: !kIsWeb
          ? FloatingActionButton(
              onPressed: () {
                ScanUtils.scanCode(context);
              },
              backgroundColor: Theme.of(context).primaryColor,
              tooltip: 'scan code',
              elevation: 5,
              splashColor: Colors.grey,
              child: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColorDark,
                size: 29,
              ),
            )
          : const SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isPromotersLoading && _isPartyInterestLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          displayBoxOfficeOptions(context),
          const Divider(),

          sOption!='add'?
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
            child: TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'search by name or phone',
                  hintStyle: TextStyle(color: Constants.primary)
              ),
              autofocus: false,
              style: const TextStyle(fontSize: 17, color: Constants.primary),
              onChanged: (val) {
                if(val.trim().isNotEmpty){
                  isSearching = true;
                } else {
                  isSearching = false;
                }

                searchList.clear();

                for(var i in mPartyGuests){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.surname.toLowerCase().contains(val.toLowerCase()) ||
                      i.phone.toLowerCase().contains(val.toLowerCase())){
                    searchList.add(i);
                  }
                }
                setState(() {
                });
              } ,
            ),
          ):const SizedBox(),
          sOption == 'add' ? showAddListPage(context) : buildGuestsList(context)
        ],
      ),
    );
  }

  displayBoxOfficeOptions(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 4,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }

  buildGuestsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartyGuestsByPartyId(widget.party.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                List<PartyGuest> arrivingRequests = [];
                List<PartyGuest> completedRequests = [];
                List<PartyGuest> unapprovedRequests = [];

                if (snapshot.data!.docs.isEmpty) {
                  return const Expanded(
                      child:
                          Center(child: Text('no guest list requests found!')));
                } else {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final PartyGuest partyGuest =
                        Fresh.freshPartyGuestMap(map, false);

                    if (partyGuest.isApproved) {
                      if (partyGuest.guestsRemaining == 0) {
                        completedRequests.add(partyGuest);
                      } else {
                        arrivingRequests.add(partyGuest);
                      }
                    } else {
                      unapprovedRequests.add(partyGuest);
                    }
                  }
                  if (sOption == mOptions.first) {
                    arrivingRequests.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    mPartyGuests = arrivingRequests;
                    return displayGuests(context, isSearching? searchList: mPartyGuests);
                  } else if (sOption == mOptions[1]) {
                    completedRequests.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    mPartyGuests = completedRequests;
                    return displayGuests(context, isSearching? searchList: mPartyGuests);
                  } else if (sOption == mOptions[2]) {
                    unapprovedRequests.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    mPartyGuests = unapprovedRequests;
                    return displayGuests(context, isSearching? searchList: mPartyGuests);
                  } else {
                    return showAddListPage(context);
                  }
                }
              } else {
                return const Expanded(
                    child:
                        Center(child: Text('no guest list requests found!')));
              }
            }
        }
      },
    );
  }

  displayGuests(BuildContext context, List<PartyGuest> guests) {
    return Expanded(
      child: ListView.builder(
        itemCount: guests.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {

          String promoterName = '';
          try{
            var searchResult = mPromoters.where((obj) => obj.id == guests[index].promoterId);
            promoterName = searchResult.first.name;
          } catch (e){
            Logx.em(_TAG, e.toString());
          }

          return PromoterBoxOfficeItem(
            partyGuest: guests[index],
            party: widget.party,
            isClickable: true,
            promoterName: promoterName,
            challenges: [],
          );
        },
      ),
    );
  }

  showAddListPage(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFieldWidget(
                label: 'add guest list',
                text: '',
                maxLines: 10,
                hintText:
                    'John Doe, 9696126969, 3\nJohn Doe, 9696126969\nJohn Doe, 3\nJohn Doe\n',
                userController: controller,
                onChanged: (lines) {
                  mLines = lines;
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'promoter',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        key: const ValueKey('promoter_dropdown'),
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(
                                color: Constants.errorColor,
                                fontSize: 16.0),
                            hintText: 'please select a promoter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 0.0),
                            )),
                        isEmpty: sPromoterName == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            // dropdownColor: Constants.background,
                            value: sPromoterName,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                sPromoterName = newValue!;

                                if (sPromoterName.isEmpty) {
                                  sPromoterId = '';
                                } else {
                                  for (Promoter promoter in mPromoters) {
                                    if (promoter.name == sPromoterName) {
                                      sPromoterId = promoter.id;
                                      break;
                                    }
                                  }
                                }

                                state.didChange(newValue);
                              });
                            },
                            items: mPromoterNames.map((String value) {
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
            ButtonWidget(
              text: '🍪 add guests',
              height: 50,
              onClicked: () {
                try {
                  List<String> splitLines = mLines.split("\n");
                  List<PartyGuest> partyGuests = [];
                  int exactCount = 0;

                  for (String line in splitLines) {
                    if(line.trim().isEmpty){
                      continue;
                    }

                    List<String> data = line.split(",");

                    PartyGuest partyGuest = Dummy.getDummyPartyGuest(false);
                    partyGuest = partyGuest.copyWith(
                        partyId: widget.party.id, promoterId: sPromoterId);

                    if (data.length == 3) {
                      // name, number and count present
                      String name = data[0];
                      int num = StringUtils.getInt(data[1].trim());
                      String phone = '91$num';
                      int guestCount = 1;
                      try {
                        guestCount = int.tryParse(data[2])!+1;
                      } catch (e) {
                        Logx.em(_TAG, e.toString());
                      }
                      partyGuest = partyGuest.copyWith(
                        name: name,
                        phone: phone,
                        guestsCount: guestCount,
                        guestStatus: 'promoter',
                        guestsRemaining: guestCount,
                      );
                      exactCount += guestCount;
                    } else if (data.length == 2) {
                      // name and number present
                      String name = data[0];
                      int num = StringUtils.getInt(data[1].trim());

                      if(num<100){
                        //guest count
                        int guestCount = num+1;
                        partyGuest = partyGuest.copyWith(
                          name: name,
                          phone: '0',
                          guestsCount: guestCount,
                          guestsRemaining: 1,
                          guestStatus: 'promoter',
                          isApproved: true,
                        );
                        exactCount += guestCount;
                      } else {
                        String phone = '91$num';
                        partyGuest = partyGuest.copyWith(
                          name: name,
                          phone: phone,
                          guestsCount: 1,
                          guestsRemaining: 1,
                          guestStatus: 'promoter',
                          isApproved: true,
                        );
                        exactCount += 1;
                      }
                    } else {
                      // only name
                      String name = data[0];
                      partyGuest = partyGuest.copyWith(
                        name: name,
                        phone: '0',
                        guestsCount: 1,
                        guestsRemaining: 1,
                        guestStatus: 'promoter',
                        isApproved: true,
                      );
                      exactCount += 1;
                    }
                    partyGuests.add(partyGuest);

                    PromoterGuest promoterGuest = Dummy.getDummyPromoterGuest();
                    promoterGuest = promoterGuest.copyWith(
                        name: partyGuest.name,
                        phone: partyGuest.phone,
                        partyGuestId: partyGuest.id,
                        promoterId: partyGuest.promoterId);

                    if(!testMode){
                      FirestoreHelper.pushPartyGuest(partyGuest);
                      FirestoreHelper.pushPromoterGuest(promoterGuest);
                    }
                  }

                  //update interest count
                  exactCount = mPartyInterest.initCount + exactCount;
                  mPartyInterest = mPartyInterest.copyWith(initCount: exactCount);

                  if(!testMode){
                    FirestoreHelper.pushPartyInterest(mPartyInterest);
                  }

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          ManageGuestsCreatedScreen(partyGuests: partyGuests, promoters: mPromoters)));
                  controller.clear();
                } catch (e) {
                  Logx.em(_TAG, e.toString());
                }
              },
            ),
            const SizedBox(height: 24),
            DarkButtonWidget(
              text: '🧞 add promoter',
              onClicked: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (ctx) => PromoterAddEditScreen(
                            promoter: Dummy.getDummyPromoter(),
                            task: 'add',
                          )),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
