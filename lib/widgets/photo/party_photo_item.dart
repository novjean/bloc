import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/entity/party_photo.dart';
import '../../main.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../utils/number_utils.dart';
import '../ui/blurred_image.dart';
import '../ui/dark_button_widget.dart';

class PartyPhotoItem extends StatefulWidget {
  PartyPhoto partyPhoto;
  int index;

  PartyPhotoItem({Key? key, required this.partyPhoto, required this.index})
      : super(key: key);

  @override
  State<PartyPhotoItem> createState() => _PartyPhotoItemState();
}

class _PartyPhotoItemState extends State<PartyPhotoItem> {
  static const String _TAG = 'PartyPhotoItem';

  @override
  Widget build(BuildContext context) {
    bool isLoved = false;

    if (widget.partyPhoto.likers.contains(UserPreferences.myUser.id)) {
      isLoved = true;
    }

    return Hero(
      tag: widget.partyPhoto.id,
      child: Card(
        elevation: 5,
        color: Constants.lightPrimary,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        child: SizedBox(
          width: mq.width,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 0.0, right: 0, bottom: 2, top: 0),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                kIsWeb
                    ? Stack(alignment: Alignment.center, children: [
                        BlurredImage(
                          imageUrl: widget.partyPhoto.imageThumbUrl.isNotEmpty
                              ? widget.partyPhoto.imageThumbUrl
                              : widget.partyPhoto.imageUrl,
                          blurLevel: 3,
                        ),
                        Positioned(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(
                                    _getRandomAppDownloadQuote(),
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        backgroundColor: Constants.lightPrimary
                                            .withOpacity(0.2)),
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DarkButtonWidget(
                                      text: '🍎 ios',
                                      onClicked: () {
                                        final uri = Uri.parse(
                                            ChallengeUtils.urlBlocAppStore);
                                        NetworkUtils.launchInBrowser(uri);
                                      },
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: DarkButtonWidget(
                                        text: '🤖 android',
                                        onClicked: () {
                                          //android download
                                          final uri = Uri.parse(
                                              ChallengeUtils.urlBlocPlayStore);
                                          NetworkUtils.launchInBrowser(uri);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ])
                    : SizedBox(
                        width: mq.width,
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/logo_3x2.png'),
                          image: NetworkImage(widget.partyPhoto.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, top: 5, bottom: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.partyPhoto.partyName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.partyPhoto.likers.length + widget.partyPhoto.initLikes}',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: InkWell(
                            onTap: () {
                              if (UserPreferences.isUserLoggedIn()) {
                                if (kIsWeb) {
                                  _showDownloadAppDialog(context);
                                } else {
                                  if (widget.partyPhoto.likers.isEmpty) {
                                    setState(() {
                                      widget.partyPhoto.likers
                                          .add(UserPreferences.myUser.id);
                                      FirestoreHelper.pushPartyPhoto(
                                          widget.partyPhoto);
                                    });
                                  } else {
                                    if (!isLoved) {
                                      setState(() {
                                        widget.partyPhoto.likers
                                            .add(UserPreferences.myUser.id);
                                        FirestoreHelper.pushPartyPhoto(
                                            widget.partyPhoto);
                                      });
                                    } else {
                                      String text = _getRandomLoveQuote();
                                      Logx.ist(_TAG, '$text 😘');
                                    }
                                  }
                                }
                              } else {
                                Logx.ist(
                                    _TAG, 'please login to like the photo');
                              }
                            },
                            child: isLoved
                                ? const Icon(
                                    Icons.favorite,
                                    size: 24.0,
                                    color: Constants.ferrari,
                                  )
                                : const Icon(Icons.favorite_border,
                                    size: 24.0)),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: InkWell(
                              onTap: () async {
                                if (UserPreferences.isUserLoggedIn()) {
                                  if (kIsWeb) {
                                    _showDownloadAppDialog(context);
                                  } else {
                                    int fileNum = widget.index + 1;
                                    String fileName =
                                        '${widget.partyPhoto.partyName} $fileNum';
                                    String shareText =
                                        'hey. check out this photo and more of ${widget.partyPhoto.partyName} at the official bloc app. Step into the moment. 📸 \n\n🌏 https://bloc.bar/#/\n📱 https://bloc.bar/app_store.html\n\n#blocCommunity ❤️‍🔥';

                                    FileUtils.sharePhoto(
                                        widget.partyPhoto.id,
                                        widget.partyPhoto.imageUrl,
                                        fileName,
                                        shareText);
                                  }
                                } else {
                                  Logx.ist(
                                      _TAG, 'please login to share the photo');
                                }
                              },
                              child: const Icon(Icons.share_outlined,
                                  size: 24.0))),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: InkWell(
                          onTap: () {
                            if (kIsWeb) {
                              _showDownloadAppDialog(context);
                            } else {
                              if (UserPreferences.isUserLoggedIn()) {
                                Logx.ist(_TAG, '🍄 downloading...');
                                int fileNum = widget.index + 1;
                                String fileName =
                                    '${widget.partyPhoto.partyName} $fileNum';

                                FileUtils.saveNetworkImage(
                                    widget.partyPhoto.imageUrl, fileName);

                                int count = widget.partyPhoto.downloadCount + 1;
                                widget.partyPhoto = widget.partyPhoto
                                    .copyWith(downloadCount: count);
                                FirestoreHelper.pushPartyPhoto(
                                    widget.partyPhoto);
                              } else {
                                Logx.ist(_TAG,
                                    'please login to save the photo to your gallery');
                              }
                            }
                          },
                          child: const Icon(Icons.save_alt, size: 24.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, top: 1, bottom: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateTimeUtils.getFormattedDate(
                          widget.partyPhoto.partyDate)),
                      const Spacer(),
                      Text(
                        '${widget.partyPhoto.views} ',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Image.asset(
                        'assets/icons/ic_third_eye.png',
                        width: 14,
                        height: 14,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDownloadAppDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'bloc app ❤️‍🔥',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: const Text(
                "ready, set, download delight! bloc app in hand, memories at hand. download our app in order to save photos to your gallery and more."),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: const Text('🤖 android',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final uri = Uri.parse(ChallengeUtils.urlBlocPlayStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: const Text('🍎 ios',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final uri = Uri.parse(ChallengeUtils.urlBlocAppStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
            ],
          );
        });
  }

  String _getRandomLoveQuote() {
    List<String> loveQuotes = [
      'In the treasury of love, once given, there\'s no withdrawal.',
      'Love\'s bond, once forged, time cannot erase or reclaim.',
      'Once love\'s stars align, they forever shimmer in the night.',
      'Love\'s touch, once felt, leaves an indelible mark on souls',
      'Once love\'s seeds are sown, they bloom into a forever garden.',
      'Love\'s like WiFi passwords – shared once, never forgotten!',
      'Love\'s return policy: \'All sales final, all hearts happy!\'',
      'Love\'s golden rule: once given, it\'s \'heart-y\' forever!',
      'Love\'s like glitter – once sprinkled, it\'s everywhere, darling!',
      'Love\'s sticky note: once stuck, it clings to hearts forever!'
    ];

    int randomNumber =
        NumberUtils.generateRandomNumber(0, loveQuotes.length - 1);
    return loveQuotes[randomNumber].toLowerCase();
  }

  String _getRandomAppDownloadQuote() {
    List<String> quotes = [
      'your view, your way. download our app to see and save.',
      'View, save, and smile with our app - your digital vault!',
      'Download the magic wand for your photos: our enchanting app!',
      'Unveil the art of seeing: our app reveals, you treasure.',
      'Embrace pixels, create memories: our app, your joyful ally.'
          'App alert: Party pics hidden until you tap \'download\'!',
      'Party pics: Exclusive backstage entry through our app doors!',
      'No app, no snaps! It\'s the golden ticket to party pics.',
      'Preserving moments of grace: Download our app, relive the night.',
      'Captured with grace, cherished through our app.',
      'A touch of grace, a world of memories. Download and cherish.'
    ];

    int randomNumber = NumberUtils.generateRandomNumber(0, quotes.length - 1);
    return quotes[randomNumber].toLowerCase();
  }
}
