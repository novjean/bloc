import 'package:bloc/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class ArtistBanner extends StatelessWidget {
  static const String _TAG = 'ArtistBanner';

  Party party;
  final bool isClickable;

  ArtistBanner(
      {Key? key,
      required this.party,
      required this.isClickable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isClickable) {
          GoRouter.of(context).pushNamed(RouteConstants.artistRouteName,
              params: {
                'name': party.name,
                'genre': party.genre
              });
        } else {
          Logx.i(_TAG, 'artist banner no click');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Hero(
          tag: party.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                height: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: NetworkImage(party.imageUrl),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 5),
                              child: Text(
                                '${party.name.toLowerCase()} ',
                                style: const TextStyle(
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(party.description.toLowerCase(),
                              maxLines: 3,
                              style: TextStyle(
                                  fontSize: 15,
                                  overflow: TextOverflow.ellipsis,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [showListenOrInstaDialog(context)],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showListenOrInstaDialog(BuildContext context) {
    bool isListen = party.listenUrl.isNotEmpty;
    bool isInsta = party.instagramUrl.isNotEmpty;

    if (!isListen && !isInsta) {
      return const SizedBox();
    }

    String source;
    if(party.listenUrl.isNotEmpty){
      source = findListenSource(party.listenUrl);
    } else {
      source = 'assets/icons/ic_instagram.png';
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.lightPrimary,
        foregroundColor: Colors.white,
        shadowColor: Colors.white30,
        elevation: 3,
        minimumSize: const Size.fromHeight(40),
      ),
      onPressed: () {
        final uri = Uri.parse(isListen ? party.listenUrl : party.instagramUrl);
        NetworkUtils.launchInBrowser(uri);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(source),
      ),
    );
  }
}

String findListenSource(String listenUrl) {
  if (listenUrl.contains('spotify')) {
    return 'assets/icons/ic_spotify.png';
  } else if (listenUrl.contains('soundcloud')) {
    return 'assets/icons/ic_soundcloud.png';
  } else if (listenUrl.contains('youtube')) {
    return 'assets/icons/ic_youtube.png';
  } else {
    return 'assets/icons/ic_play.png';
  }
}

