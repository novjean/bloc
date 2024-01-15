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
import '../box_office/promoter_box_office_tix_screen.dart';

class PromoterPartyTixsScreen extends StatefulWidget {
  final Party party;

  const PromoterPartyTixsScreen({Key? key, required this.party}) : super(key: key);

  @override
  State<PromoterPartyTixsScreen> createState() => _PromoterPartyTixsScreenState();
}

class _PromoterPartyTixsScreenState extends State<PromoterPartyTixsScreen> {
  static const String _TAG = 'PromoterPartyTixsScreen';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showActionsDialog(context);
      //   },
      //   backgroundColor: Theme.of(context).primaryColor,
      //   tooltip: 'actions',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      //   child: const Icon(
      //     Icons.science,
      //     color: Colors.black,
      //     size: 29,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          _isSearching ? _displayTixs(context, searchList): _loadTixsList(context)
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
      stream: FirestoreHelper.getTixsByPartyId(widget.party.id),
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

                  return _displayTixs(context, mTixs);
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
                  builder: (context) => PromoterBoxOfficeTixScreen(tixId: tixs[index].id)));
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
}
