import 'package:bloc/screens/manager/lounges/lounge_add_edit_screen.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/lounge.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/manager/manage_lounge_item.dart';
import '../../../widgets/ui/loading_widget.dart';

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
      body: _loadLounges(context),

    );
  }

  _loadLounges(BuildContext context) {
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
                List<Lounge> lounges = [];

                if (snapshot.data!.docs.isNotEmpty) {
                  try {
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot document = snapshot.data!.docs[i];
                      Map<String, dynamic> map =
                      document.data()! as Map<String, dynamic>;
                      final Lounge lounge = Fresh.freshLoungeMap(map, false);
                      lounges.add(lounge);
                    }
                    return _showLounges(context, lounges);
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

  _showLounges(BuildContext context, List<Lounge> lounges) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: lounges.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Lounge lounge = lounges[index];

            return GestureDetector(
                child: ManageLoungeItem(
                  lounge: lounge,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => LoungeAddEditScreen(
                        lounge: lounge,
                        task: 'edit',
                      )));
                });
          }),
    );
  }

}