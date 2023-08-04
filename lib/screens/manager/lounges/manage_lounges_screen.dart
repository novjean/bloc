import 'package:bloc/screens/manager/lounges/lounge_add_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/lounge.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/listview_block.dart';
import '../../../widgets/ui/loading_widget.dart';

class ManageLoungesScreen extends StatefulWidget {

  const ManageLoungesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ManageLoungesScreenState();
}

class _ManageLoungesScreenState extends State<ManageLoungesScreen> {
  static const String _TAG = 'ManageLoungesScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('manage lounges')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) =>
                    LoungeAddEditScreen(lounge: Dummy.getDummyLounge(),task: 'add',)),
          );
        },
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        tooltip: 'new lounge',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 2.0),
        // _displayOptions(context),
        // const Divider(),
        const SizedBox(height: 5.0),
        loadLounges(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  loadLounges(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getLounges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          List<Lounge> lounges = [];

          if (snapshot.data!.docs.isNotEmpty) {
            try {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> map =
                document.data()! as Map<String, dynamic>;
                final Lounge lounge = Fresh.freshLoungeMap(map, false);
                lounges.add(lounge);

                if (i == snapshot.data!.docs.length - 1) {
                  return showLounges(context, lounges);
                }
              }
            } on Exception catch (e, s) {
              Logx.e(_TAG, e, s);
            } catch (e) {
              Logx.em(_TAG, 'error loading lounges : $e');
            }
          }
          return const LoadingWidget();
        });
  }

  showLounges(BuildContext context, List<Lounge> lounges) {
    return Expanded(
      child: ListView.builder(
          itemCount: lounges.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            Lounge lounge = lounges[index];

            return GestureDetector(
                child: ListViewBlock(
                  title: lounge.name,
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