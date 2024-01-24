import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/organizer.dart';
import '../../db/entity/party.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/footer.dart';
import '../../widgets/organizer/organizer_party_banner.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/app_bar_title.dart';

class OrganizerScreen extends StatefulWidget {

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  static const String _TAG = 'OrganizerScreen';

  late Organizer mOrganizer;
  var _isOrganizerLoading = true;

  List<Party> mParties = [];

  @override
  void initState() {
    FirestoreHelper.pullOrganizer(UserPreferences.myUser.id).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mOrganizer = Fresh.freshOrganizerMap(data, false);

        setState(() {
          _isOrganizerLoading = false;
        });
      } else {
        // user is not an organizer
        Navigator.of(context).pop();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: 'organizer'),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: _isOrganizerLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context){
    return ListView(
      physics: const BouncingScrollPhysics(),
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
                child: Text(mOrganizer.name.toLowerCase(),
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
                  imagePath: mOrganizer.imageUrl,
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

        const SizedBox(height: 36,),
        Footer()
      ],
    );
  }

  _loadOrganizerEvents(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getPartiesByOrganizer(mOrganizer.id),
      builder: (ctx, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const LoadingWidget();
          case ConnectionState.active:
          case ConnectionState.done: {
            Logx.d(_TAG, 'load organizer parties is done');

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
                }
              }

              if(mParties.isNotEmpty){
                return _displayParties(context);
              } else {
                Logx.em(_TAG, 'parties came in empty!');
                return Center(child: Text('no parties hosted yet!'),);
              }
            } catch (e) {
              Logx.em(_TAG, 'parties get failed. $e');
              return Center(child: Text('no parties found!'),);
            }
          }
        }
      },
    );
  }

  _displayParties(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mParties.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Party party = mParties[index];

          return OrganizerPartyBanner(
            party: party,
            isClickable: true,
            shouldShowButton: true,
            isGuestListRequested: false,
            shouldShowInterestCount: true,
          );
        },
      ),
    );
  }
}