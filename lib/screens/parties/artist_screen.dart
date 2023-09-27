import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';

import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/store_badge_item.dart';

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

        FirestoreHelper.updatePartyViewCount(mParty.id);
      } else {
        Logx.est(_TAG, 'sorry, the artist could not be found');

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
          title: AppBarTitle (title: mParty.name.toLowerCase()),
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if(UserPreferences.isUserLoggedIn()){
                GoRouter.of(context)
                    .pushNamed(RouteConstants.homeRouteName);
              } else {
                GoRouter.of(context)
                    .pushNamed(RouteConstants.landingRouteName);
              }
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
              mParty.imageUrls.length > 1
                  ? CarouselSlider(
                options: CarouselOptions(
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration:
                  const Duration(milliseconds: 1200),
                  scrollDirection: Axis.horizontal,
                  aspectRatio: mParty.isSquare ? 1.33: 1.0,
                ),
                items: mParty.imageUrls
                    .map((item) => kIsWeb
                    ? SizedBox(
                  width: double.infinity,
                  child: Image.network(item,
                      width: double.infinity,
                      fit: BoxFit.cover),
                )
                    : CachedNetworkImage(
                  imageUrl: item,
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  placeholder: (context, url) =>
                  const FadeInImage(
                    placeholder:
                    AssetImage('assets/images/logo.png'),
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ))
                    .toList(),
              )
                  : SizedBox(
                  width: double.infinity,
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/logo.png'),
                    image: NetworkImage(mParty.showStoryImageUrl
                        ? mParty.storyImageUrl
                        : mParty.imageUrl),
                    fit: BoxFit.contain,
                  )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: RichText(
                        text: TextSpan(
                            text: '${mParty.name.toLowerCase()} ',
                            style: const TextStyle(
                                fontFamily: Constants.fontDefault,
                                color: Constants.lightPrimary,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                  text: mParty.chapter == 'I'
                                      ? ' '
                                      : mParty.chapter,
                                  style: const TextStyle(
                                      fontFamily: Constants.fontDefault,
                                      color: Constants.lightPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic)),
                            ]),
                      ),
                    ),
                  ),
                  // Flexible(
                  //   flex: 1,
                  //   child: _showFollowButton(context),
                  // ),
                ],
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
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text('listen',
                        style: TextStyle(
                            color: Constants.lightPrimary,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )
                  : const SizedBox(),
              mParty.listenUrl.isNotEmpty
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      final uri = Uri.parse(mParty.listenUrl);
                      NetworkUtils.launchInBrowser(uri);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      child: Text('${findListenSource(mParty.listenUrl)} 🎧 ',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Constants.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : const SizedBox(),
              const SizedBox(height: 10),
              mParty.instagramUrl.isNotEmpty
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text('links',
                        style: TextStyle(
                            color: Constants.lightPrimary,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )
                  : const SizedBox(),
              mParty.instagramUrl.isNotEmpty
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      final uri = Uri.parse(mParty.instagramUrl);
                      NetworkUtils.launchInBrowser(uri);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      child: Text(
                        'instagram 🧡',
                        style: TextStyle(
                          fontSize: 18,
                          color: Constants.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : const SizedBox(),
              const SizedBox(height: 15.0),
              kIsWeb ? const StoreBadgeItem() : const SizedBox(),
              const SizedBox(height: 10.0),
              Footer(),            ],
          );
  }

  String findListenSource(String listenUrl) {
    if (listenUrl.contains('spotify')) {
      return 'spotify';
    } else if (listenUrl.contains('soundcloud')) {
      return 'soundcloud';
    } else if (listenUrl.contains('youtube')) {
      return 'youtube';
    } else {
      return 'other';
    }
  }

  _showFollowButton(BuildContext context) {
    return Container(
      height: 50,
      width: 160,
      padding: const EdgeInsets.only(left: 5, right: 10, bottom: 1, top: 1),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primary,
          foregroundColor: Constants.background,
          shadowColor: Colors.white30,
          elevation: 3,
          // minimumSize: const Size.fromHeight(60),
        ),
        onPressed: () {

        },
        icon: const Icon(
          Icons.square_outlined,
          size: 22.0,
        ),
        label: const Text(
          'follow',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Constants.darkPrimary),
        ),
      ),
    );
  }
}
