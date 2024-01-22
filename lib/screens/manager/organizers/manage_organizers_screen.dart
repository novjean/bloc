import 'package:bloc/db/entity/organizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../widgets/manager/manage_organizer_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'organizer_add_edit_screen.dart';

class ManageOrganizersScreen extends StatelessWidget {
  static const String _TAG = 'ManageOrganizersScreen';

  String serviceId;

  ManageOrganizersScreen({Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage organizers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => OrganizerAddEditScreen(
                  organizer: Dummy.getDummyOrganizer(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Constants.primary,
        tooltip: 'add organizer',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildOrganizers(context),
    );
  }

  _buildOrganizers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getOrganizers(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Organizer> organizers = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> map = document.data()! as Map<
                      String,
                      dynamic>;
                  final Organizer _organizer = Fresh.freshOrganizerMap(map, false);
                  organizers.add(_organizer);
                }
                return _displayOrganizers(context, organizers);
              }
          }
        });
  }

  _displayOrganizers(BuildContext context, List<Organizer> organizers) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: organizers.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageOrganizerItem(
                  organizer: organizers[index],
                ),
                onTap: () {
                  Organizer sOrganizer = organizers[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => OrganizerAddEditScreen(
                          organizer: sOrganizer,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
