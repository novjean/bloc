import 'dart:io';

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/organizer.dart';
import '../../db/entity/party.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/number_utils.dart';
import '../../utils/string_utils.dart';
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
    FirestoreHelper.pullOrganizer(UserPreferences.myUser.id).then((res) async {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mOrganizer = Fresh.freshOrganizerMap(data, false);

        setState(() {
          _isOrganizerLoading = false;
        });
      } else {
        // user is not an organizer
        Logx.ilt(_TAG, '🪅 setting up your event company...');



        if(UserPreferences.isUserLoggedIn()){
          //upload random photo
          String assetFileName = '';
          int photoNum = NumberUtils.getRandomNumber(1,5);
          assetFileName = 'assets/organizer_photos/$photoNum.jpeg';

          File imageFile = await FileUtils.getAssetImageAsFile(assetFileName);
          String imageUrl = await FirestorageHelper.uploadFile(
              FirestorageHelper.ORGANIZER_IMAGES,
              StringUtils.getRandomString(28),
              imageFile);

          mOrganizer = Dummy.getDummyOrganizer().copyWith(
            name: '${UserPreferences.myUser.name} ${UserPreferences.myUser.surname} event co.',
            ownerId: UserPreferences.myUser.id,
            imageUrl: imageUrl,
            phoneNumber: UserPreferences.myUser.phoneNumber,
          );

          FirestoreHelper.pushOrganizer(mOrganizer);

          setState(() {
            _isOrganizerLoading = false;
          });
        } else {
          Navigator.of(context).pop();
          Logx.est(_TAG, 'something went wrong, please try again');
        }
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
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: _isOrganizerLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
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
                      child: Text(
                        mOrganizer.name,
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
              const SizedBox(
                height: 15,
              ),
              _loadOrganizerEvents(context),
              Footer(
                showAll: false,
              )
            ],
          );
        // : const Expanded(
        //     child: Center(
        //       child: Text(
        //         'you are not an event organizer yet!',
        //         style: TextStyle(color: Constants.primary),
        //       ),
        //     ),
        //   );
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
          case ConnectionState.done:
            {
              Logx.d(_TAG, 'load organizer parties is done');

              try {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
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

                if (mParties.isNotEmpty) {
                  return _displayParties(context);
                } else {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'you have not hosted an event yet!',
                        style: TextStyle(color: Constants.primary),
                      ),
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //
                    //     const SizedBox(height: 36,),
                    //     ButtonWidget(
                    //       text: 'add event',
                    //       onClicked: () {
                    //       Logx.ist(_TAG, 'adding your event');
                    //     },)
                    // ]
                    // ),
                  );
                }
              } catch (e) {
                return const Center(
                  child: Text('no hosted events found!'),
                );
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
