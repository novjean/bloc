import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/network_utils.dart';
import '../../widgets/ui/button_widget.dart';

class ArtistScreen extends StatefulWidget {
  final String name;
  final String genre;

  const ArtistScreen({required this.name, required this.genre, Key? key})
      : super(key: key);

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  static const String _TAG = 'ArtistScreen';

  Party mParty = Dummy.getDummyParty('');
  var isPartyLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullPartyByNameGenre(widget.name, widget.genre).then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party party = Fresh.freshPartyMap(data, false);
          mParty = party;
        }

        setState(() {
          isPartyLoading = false;
        });
      } else {
        setState(() {
          isPartyLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: InkWell(
              onTap: () {
                if(UserPreferences.isUserLoggedIn()){
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.homeRouteName);
                } else {
                  GoRouter.of(context)
                      .pushNamed(RouteConstants.landingRouteName);
                }
              },
              child: AppBarTitle (title: mParty.name.toLowerCase())),
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Constants.background,
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return isPartyLoading
        ? const LoadingWidget()
        : ListView(
            children: [
              SizedBox(
                width: double.infinity,
                child: Hero(
                  tag: mParty.id,
                  child: Image.network(
                    mParty.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(mParty.name.toLowerCase(),
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 26,
                    )),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(mParty.description.toLowerCase(),
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 20,
                    )),
              ),
              const SizedBox(height: 10),
              mParty.listenUrl.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ButtonWidget(
                              text:
                                  'listen' + findListenSource(mParty.listenUrl),
                              onClicked: () {
                                final uri = Uri.parse(mParty.listenUrl);
                                NetworkUtils.launchInBrowser(uri);
                              }),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  : const SizedBox(),
              mParty.instagramUrl.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ButtonWidget(
                              text: 'social profile',
                              onClicked: () {
                                final uri = Uri.parse(mParty.instagramUrl);
                                NetworkUtils.launchInBrowser(uri);
                              }),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 10),
            ],
          );
  }

  String findListenSource(String listenUrl) {
    if (listenUrl.contains('spotify')) {
      return ' on spotify';
    } else if (listenUrl.contains('soundcloud')) {
      return ' on soundcloud';
    } else if (listenUrl.contains('youtube')) {
      return ' on youtube';
    } else {
      return '';
    }
  }
}
