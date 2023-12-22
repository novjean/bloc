import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../api/apis.dart';
import '../../../db/entity/party.dart';
import '../../../db/entity/tix.dart';
import '../../../db/entity/tix_tier_item.dart';
import '../../../db/entity/user.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/file_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/box_office/promoter_tix_data_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import 'manage_box_office_tix_screen.dart';

class ManagePartyTixsScreen extends StatefulWidget {
  final Party party;

  const ManagePartyTixsScreen({Key? key, required this.party}) : super(key: key);

  @override
  State<ManagePartyTixsScreen> createState() => _ManagePartyTixsScreenState();
}

class _ManagePartyTixsScreenState extends State<ManagePartyTixsScreen> {
  static const String _TAG = 'ManagePartyTixsScreen';

  bool testMode = false;

  List<Tix> mTixs = [];

  late List<String> mOptions;
  late String sOption;

  List<Tix> searchList = [];
  bool _isSearching = false;
  String mLines = '';
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();

    mOptions = ['arriving', 'completed'];
    sOption = mOptions.first;

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionsDialog(context);
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          displayBoxOfficeOptions(context),
          const Divider(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
            child: TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'search by name or phone',
                  hintStyle: TextStyle(color: Constants.primary)),
              autofocus: false,
              style: const TextStyle(fontSize: 17, color: Constants.primary),
              onChanged: (val) {
                if (val.trim().isNotEmpty) {
                  _isSearching = true;
                } else {
                  _isSearching = false;
                }

                searchList.clear();

                for (var i in mTixs) {
                  if (i.userName.toLowerCase().contains(val.toLowerCase()) ||
                      i.userPhone.toLowerCase().contains(val.toLowerCase())) {
                    searchList.add(i);
                  }
                }
                setState(() {});
              },
            ),
          ),
          _isSearching ? _displayTixs(context, searchList) : _loadTixsList(context)
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
                  color: Constants.primary,
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

  _loadTixsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getAllTixsByPartyId(widget.party.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Expanded(
                      child: Center(child: Text('no tixs found!')));
                } else {
                  mTixs.clear();

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                    final Tix tix = Fresh.freshTixMap(map, false);
                    mTixs.add(tix);
                  }

                  return _displayTixs(
                      context, mTixs);
                }
              } else {
                return const Expanded(
                    child: Center(child: Text('no tixs found!')));
              }
            }
        }
      },
    );
  }

  _displayTixs(BuildContext context, List<Tix> tixs) {
    return Expanded(
      child: ListView.builder(
        itemCount: tixs.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ManageBoxOfficeTixScreen(tixId: tixs[index].id)));
            },
            child: PromoterTixDataItem(
              tix: tixs[index],
              party: widget.party,
              isClickable: true,
            ),
          );
        },
      ),
    );
  }

  _showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: _actionsList(ctx),
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

  _actionsList(BuildContext ctx) {
    return SizedBox(
      height: mq.height * 0.5,
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
              height: mq.height * 0.45,
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
                                onTap: () async {
                                  Navigator.of(ctx).pop();

                                  String tixText = '';
                                  for (Tix tix in mTixs) {
                                    await FirestoreHelper.pullTixTiersByTixId(tix.id).then((res) {
                                      if (res.docs.isNotEmpty) {
                                        int count = 0;

                                        for (int i = 0; i < res.docs.length; i++) {
                                          DocumentSnapshot document = res.docs[i];
                                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
                                          count += tixTier.tixTierCount;
                                        }
                                        tixText += '${tix.userName},${tix.userPhone},'
                                            '+${tix.userEmail},${tix.total},$count pax,\n';

                                      } else {
                                        Logx.em(_TAG, 'no tix tiers found for ${tix.id}');
                                      }
                                    });
                                  }

                                  String rand = StringUtils.getRandomString(5);
                                  String fileName = '${widget.party.name}-$rand.csv';
                                  FileUtils.shareCsvFile(
                                      fileName, tixText, widget.party.name);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.share_outlined,
                                        color: Colors.lightBlue),
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

                                  String tixText = '';
                                  for (Tix tix in mTixs) {
                                    await FirestoreHelper.pullTixTiersByTixId(tix.id).then((res) {
                                      if (res.docs.isNotEmpty) {
                                        int count = 0;

                                        for (int i = 0; i < res.docs.length; i++) {
                                          DocumentSnapshot document = res.docs[i];
                                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
                                          count += tixTier.tixTierCount;
                                        }
                                        tixText += '${tix.userName},+${tix.userPhone},${tix.total},$count pax,\n';

                                      } else {
                                        Logx.em(_TAG, 'no tix tiers found for ${tix.id}');
                                      }
                                    });
                                  }

                                  String rand = StringUtils.getRandomString(5);
                                  String fileName = '${widget.party.name}-$rand.csv';
                                  FileUtils.shareCsvFile(
                                      fileName, tixText, widget.party.name);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.share_outlined,
                                        color: Colors.lightBlue),
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
                        const Text('delete unsuccessful'),
                        SizedBox.fromSize(
                          size: const Size(50, 50),
                          child: ClipOval(
                            child: Material(
                              color: Constants.darkPrimary,
                              child: InkWell(
                                splashColor: Constants.primary,
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _showDeleteAllUnsuccessfulTickets(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.delete_forever,
                                      color: Constants.errorColor,
                                    ),
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
                                  _showGoogleReviewBlocDialog(context);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.delete_forever,
                                      color: Constants.errorColor,
                                    ),
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
    );
  }

  _showGoogleReviewBlocDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'request google review from all ${widget.party.name} tix holders',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'request for google review from ${mTixs.length} tix holders. are you sure you want to ask?'),
            actions: [
              TextButton(
                child: const Text('review bloc'),
                onPressed: () async {
                  for (Tix tix in mTixs) {
                    FirestoreHelper.pullUser(tix.userId).then((res) {
                      if (res.docs.isNotEmpty) {
                        DocumentSnapshot document = res.docs[0];
                        Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
                        User user = Fresh.freshUserMap(map, true);

                        if(user.fcmToken.isNotEmpty){
                          if(!user.isAppReviewed &&
                              user.lastReviewTime < Timestamp.now().millisecondsSinceEpoch - (2 * DateTimeUtils.millisecondsWeek)){
                            //send a notification
                            Apis.sendUrlData(user.fcmToken, Apis.GoogleReviewBloc, Constants.blocGoogleReview);
                            Logx.ist(_TAG,
                                '${user.name} ${user.surname} has been notified for a bloc google review 🤞');

                            user = user.copyWith(
                                lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                            FirestoreHelper.pushUser(user);
                          } else {
                            Logx.ist(_TAG, '${user.name} ${user.surname} has already google reviewed 🤞');
                          }
                        }
                      } else {
                        Logx.est(_TAG, 'user in ticket not found in db : ${tix.userId}');
                      }
                    });
                  }

                  Navigator.of(ctx).pop();
                  _showDeleteAllTickets(context);
                },
              ),
              TextButton(
                child: const Text('review freq'),
                onPressed: () async {
                  for (Tix tix in mTixs) {
                    FirestoreHelper.pullUser(tix.userId).then((res) {
                      if (res.docs.isNotEmpty) {
                        DocumentSnapshot document = res.docs[0];
                        Map<String, dynamic> map = document.data()! as Map<
                            String,
                            dynamic>;
                        User user = Fresh.freshUserMap(map, true);

                        if (user.fcmToken.isNotEmpty) {
                          if (!user.isAppReviewed &&
                              user.lastReviewTime < Timestamp
                                  .now().millisecondsSinceEpoch -
                                  (2 * DateTimeUtils.millisecondsWeek)) {
                            //send a notification
                            Apis.sendUrlData(
                                user.fcmToken, Apis.GoogleReviewFreq,
                                Constants.freqGoogleReview);
                            Logx.ist(_TAG,
                                '${user.name} ${user
                                    .surname} has been notified for a freq google review 🤞');
                            user = user.copyWith(
                                lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                            FirestoreHelper.pushUser(user);
                          } else {
                            Logx.ist(_TAG, '${user.name} ${user
                                .surname} has already google reviewed 🤞');
                          }
                        }
                      }
                    });
                  }

                  Navigator.of(ctx).pop();
                  _showDeleteAllTickets(context);
                },
              ),

              TextButton(
                child: const Text("no"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showDeleteAllTickets(context);
                },
              )
            ],
          );
        });
  }

  _showDeleteAllTickets(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'delete all ${widget.party.name} tickets',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: Text(
                'deleting ${mTixs.length} tickets. are you sure you want to continue?'),
            actions: [
              TextButton(
                child: const Text('yes'),
                onPressed: () {
                  for (Tix tix in mTixs) {
                    FirestoreHelper.deleteTix(tix.id);
                    FirestoreHelper.pullTixTiersByTixId(tix.id).then((res) {
                      if (res.docs.isNotEmpty) {
                        for (int i = 0; i < res.docs.length; i++) {
                          DocumentSnapshot document = res.docs[i];
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          final TixTier tixTier = Fresh.freshTixTierMap(data, false);
                          FirestoreHelper.deleteTixTier(tixTier.id);
                        }
                      } else {
                        Logx.em(_TAG, 'no tix tiers found for ${tix.id}');
                      }
                    });
                  }
                  Logx.ist(_TAG, 'deleted all ${widget.party.name} tickets!');
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text("no"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  _showDeleteAllUnsuccessfulTickets(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'delete all unsuccessful ${widget.party.name} tickets',
              style: const TextStyle(color: Colors.redAccent),
            ),
            content: const Text(
                'deleting all unsuccessful tickets. are you sure you want to continue?'),
            actions: [
              TextButton(
                child: const Text('yes'),
                onPressed: () {
                  for (Tix tix in mTixs) {
                    if(tix.transactionId.isEmpty){

                    }

                    // FirestoreHelper.deleteTix(tix.id);
                    // FirestoreHelper.pullTixTiersByTixId(tix.id).then((res) {
                    //   if (res.docs.isNotEmpty) {
                    //     for (int i = 0; i < res.docs.length; i++) {
                    //       DocumentSnapshot document = res.docs[i];
                    //       Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    //       final TixTier tixTier = Fresh.freshTixTierMap(data, false);
                    //       FirestoreHelper.deleteTixTier(tixTier.id);
                    //     }
                    //   } else {
                    //     Logx.em(_TAG, 'no tix tiers found for ${tix.id}');
                    //   }
                    // });
                  }
                  Logx.ist(_TAG, 'deleted all ${widget.party.name} tickets!');
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text("no"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }


}
