import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/tix.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_tix_item.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../parties/tix_buy_edit_screen.dart';

class ManageTicketsScreen extends StatefulWidget {

  const ManageTicketsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ManageTicketsScreenState();
}

class _ManageTicketsScreenState extends State<ManageTicketsScreen> {
  static const String _TAG = 'ManageTicketsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title:'manage tickets'),
        titleSpacing: 0,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //           builder: (ctx) =>
      //               LoungeAddEditScreen(lounge: Dummy.getDummyLounge(),task: 'add',)),
      //     );
      //   },
      //   backgroundColor: Constants.primary,
      //   tooltip: 'new lounge',
      //   elevation: 5,
      //   splashColor: Colors.grey,
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.black,
      //     size: 29,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loadTickets(context),

    );
  }

  _loadTickets(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getTixs(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Tix> tixs = [];

                if (snapshot.data!.docs.isNotEmpty) {
                  try {
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot document = snapshot.data!.docs[i];
                      Map<String, dynamic> map =
                      document.data()! as Map<String, dynamic>;
                      final Tix tix = Fresh.freshTixMap(map, false);
                      tixs.add(tix);
                    }
                    return _showTickets(context, tixs);
                  } on Exception catch (e, s) {
                    Logx.e(_TAG, e, s);
                  } catch (e) {
                    Logx.em(_TAG, 'error loading tixs : $e');
                  }
                }
              }
          }
          return const LoadingWidget();
        });
  }

  _showTickets(BuildContext context, List<Tix> tixs) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: tixs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Tix tix = tixs[index];

            return GestureDetector(
                child: ManageTixItem(
                  tix: tix,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => TixBuyEditScreen(
                        tix: tix,
                        task: 'edit',
                      )));
                });
          }),
    );
  }

}