import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/box_office/promoter_tix_data_item.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';
import '../box_office/promoter_box_office_tix_screen.dart';

class OrganizerPartySalesScreen extends StatefulWidget {
  final Party party;

  const OrganizerPartySalesScreen({super.key, required this.party});

  @override
  State<OrganizerPartySalesScreen> createState() => _OrganizerPartySalesScreenState();
}

class _OrganizerPartySalesScreenState extends State<OrganizerPartySalesScreen> {
  static const String _TAG = 'OrganizerPartySalesScreen';

  late List<String> mOptions;
  String sOption = '';

  List<Tix> mTixs = [];

  @override
  void initState() {
    mOptions = ['tickets', 'sales'];
    sOption = mOptions.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'sales',),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _showDisplayOptions(context),
          const Divider(color: Constants.darkPrimary),
          sOption == mOptions.first ? _loadTixsList(context) :
          // _loadSalesReport()
          const SizedBox()
        ],
      ),
    );
  }

  _showDisplayOptions(BuildContext context) {
    double containerHeight = 50;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: 50,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Constants.primary,
                ),
                onTap: () {
                  Logx.i(_TAG, '$sOption at sales is selected');
                  setState(() {
                    sOption = mOptions[index];
                  });
                });
          }),
    );
  }

  _loadTixsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getTixsSuccessfulByPartyId(widget.party.id),
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
                      child: Center(
                          child: Text('no tickets have been sold yet!',
                            style: TextStyle(color: Constants.primary),)));
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
                    child: Center(
                        child: Text('no tickets have been sold yet!',
                      style: TextStyle(color: Constants.primary),)));
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