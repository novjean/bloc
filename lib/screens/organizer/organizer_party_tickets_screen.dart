import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/dialog_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../db/entity/tix.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/scan_utils.dart';
import '../../widgets/box_office/promoter_tix_data_item.dart';
import '../../widgets/footer.dart';
import '../../widgets/ui/loading_widget.dart';
import '../box_office/confirm_tix_screen.dart';

class OrganizerPartyTicketsScreen extends StatefulWidget {
  final Party party;

  const OrganizerPartyTicketsScreen({super.key, required this.party});

  @override
  State<OrganizerPartyTicketsScreen> createState() => _OrganizerPartyTicketsScreenState();
}

class _OrganizerPartyTicketsScreenState extends State<OrganizerPartyTicketsScreen> {
  static const String _TAG = 'OrganizerPartyTicketsScreen';

  List<Tix> mTixs = [];

  @override
  void initState() {
    Logx.ist(_TAG, '${widget.party.name} ${widget.party.chapter} tickets');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(
          title: 'tickets',
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Constants.lightPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton(
          onPressed: () {
            if(!kIsWeb){
              ScanUtils.scanCode(context);
            } else {
              DialogUtils.showDownloadAppDialog(context);
            }
          },
          backgroundColor: Constants.primary,
          tooltip: 'scan tix',
          elevation: 5,
          splashColor: Colors.grey,
          child: const Icon(
            Icons.qr_code_scanner,
            color: Constants.darkPrimary,
            size: 29,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _loadTixsList(context),
        Footer(showAll: false,)
      ],
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
                    style: TextStyle(color: Constants.primary),
                  )));
                } else {
                  mTixs.clear();

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final Tix tix = Fresh.freshTixMap(map, false);
                    mTixs.add(tix);
                  }

                  return _displayTixs(context);
                }
              } else {
                return const Expanded(
                    child: Center(
                        child: Text(
                  'no tickets have been sold yet!',
                  style: TextStyle(color: Constants.primary),
                )));
              }
            }
        }
      },
    );
  }

  _displayTixs(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: mTixs.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ConfirmTixScreen(tixId: mTixs[index].id)));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
              child: PromoterTixDataItem(
                tix: mTixs[index],
                party: widget.party,
                isClickable: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
