import 'package:bloc/db/entity/organizer.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/party.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../widgets/organizer/organizer_party_banner.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/app_bar_title.dart';

class ManageOrganizerScreen extends StatefulWidget {
  Organizer organizer;

  ManageOrganizerScreen({super.key, required this.organizer});

  @override
  State<ManageOrganizerScreen> createState() => _ManageOrganizerScreenState();
}

class _ManageOrganizerScreenState extends State<ManageOrganizerScreen> {
  static const String _TAG = 'ManageOrganizerScreen';

  var _isOrganizerLoading = true;
  var _isUserOrganizer = false;

  List<Party> mParties = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'manage organizer'),
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

  _buildBody(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10.0),
                child: Text(widget.organizer.name.toLowerCase(),
                  maxLines: 3,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Constants.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: ProfileWidget(
                  isEdit: false,
                  imagePath: widget.organizer.imageUrl,
                  showEditIcon: false,
                  onClicked: () {
                    //nothing to do here
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15,),
        _loadOrganizerEvents(context),
        // Footer()
      ],
    );
  }

  _loadOrganizerEvents(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartiesByOrganizer(widget.organizer.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done: {
            try {
              if(snapshot.hasData){
                if(snapshot.data!.docs.isNotEmpty){
                  mParties.clear();

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                    document.data()! as Map<String, dynamic>;
                    final Party party = Fresh.freshPartyMap(map, false);
                    mParties.add(party);
                  }

                  if(mParties.isNotEmpty){
                    return _displayParties(context);
                  } else {
                    Logx.em(_TAG, 'parties came in empty!');
                    return const Center(child: Text('no parties hosted yet!'),);
                  }
                }
              }

              return LoadingWidget();

            } catch (e) {
              Logx.em(_TAG, 'parties get failed. $e');
              return const Center(child: Text('no parties found!'),);
            }
          }
        }
      },
    );
  }

  _displayParties(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        key: UniqueKey(),
        itemCount: mParties.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Party party = mParties[index];

          return OrganizerPartyBanner(
            party: party,
            shouldShowInterestCount: false,
          );
        },
      ),
    );
  }
}