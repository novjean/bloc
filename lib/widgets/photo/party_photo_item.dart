import 'package:bloc/db/entity/lounge_chat.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/file_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../db/entity/lounge.dart';
import '../../db/entity/party_photo.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../../utils/number_utils.dart';
import '../ui/blurred_image.dart';
import '../ui/dark_button_widget.dart';
import '../ui/textfield_widget.dart';

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

  String photoChatMessage = '';

  List<Lounge> sLounges = [];

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
            padding: const EdgeInsets.only(bottom: 2),
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
                          blurLevel: 5,
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
                          padding: const EdgeInsets.only(left: 20.0),
                          child: InkWell(
                              onTap: () async {
                                if (UserPreferences.isUserLoggedIn()) {
                                  if (kIsWeb) {
                                    _showDownloadAppDialog(context);
                                  } else {
                                    _showShareOptionsDialog(context);
                                  }
                                } else {
                                  Logx.ist(
                                      _TAG, 'please login to share the photo');
                                }
                              },
                              child: const Icon(Icons.share_outlined,
                                  size: 24.0))),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
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
        builder: (BuildContext ctx) {
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
                  Navigator.of(ctx).pop();
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

  _showShareOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(
            'share options',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.75,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('share to lounge'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        _showLoungeChatDialog(context);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('share to external app'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        Navigator.of(ctx).pop();

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
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showLoungeChatDialog(BuildContext context) {
    FirestoreHelper.pullLounges().then((res) {
      if (res.docs.isNotEmpty) {
        List<Lounge> lounges = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final Lounge lounge = Fresh.freshLoungeMap(map, false);

          if (UserPreferences.getListLounges().contains(lounge.id)) {
            lounges.add(lounge);
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              backgroundColor: Constants.lightPrimary,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.all(16.0),
              content: SizedBox(
                height: mq.height * 0.6,
                width: mq.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: Text(
                          'share photo to lounge',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height:12),
                      MultiSelectDialogField(
                        items: lounges
                            .map((e) => MultiSelectItem(e, e.name))
                            .toList(),
                        initialValue: sLounges.map((e) => e).toList(),
                        listType: MultiSelectListType.CHIP,
                        buttonIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade700,
                        ),
                        title: const Text('select lounges to share'),
                        buttonText: const Text(
                          'select lounge *',
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                            width: 0.0,
                          ),
                        ),
                        searchable: true,
                        onConfirm: (values) {
                          sLounges = values as List<Lounge>;
                        },
                      ),
                      const SizedBox(height:12),
                      Center(
                          child: SizedBox(
                        width: mq.width,
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/logo_3x2.png'),
                          image: NetworkImage(
                              widget.partyPhoto.imageThumbUrl.isNotEmpty
                                  ? widget.partyPhoto.imageThumbUrl
                                  : widget.partyPhoto.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      )),
                      TextFieldWidget(
                        text: '',
                        maxLines: 3,
                        onChanged: (text) {
                          photoChatMessage = text;
                        },
                        label: 'message',
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("cancel"),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Constants
                        .darkPrimary), // Set your desired background color
                  ),
                  child: const Text(
                    "💌 send",
                    style: TextStyle(color: Constants.primary),
                  ),
                  onPressed: () {
                    if (sLounges.isNotEmpty) {
                      String message =
                          '${widget.partyPhoto.imageUrl},$photoChatMessage';

                      for (Lounge lounge in sLounges) {
                        LoungeChat chat = Dummy.getDummyLoungeChat();
                        chat = chat.copyWith(
                          message: message,
                          type: 'image',
                          loungeId: lounge.id,
                          loungeName: lounge.name,
                        );

                        FirestoreHelper.pushLoungeChat(chat);
                        FirestoreHelper.updateLoungeLastChat(lounge.id, '📸 $photoChatMessage', chat.time);
                      }

                      Logx.ist(_TAG, 'photo has been shared 💝');
                      Navigator.of(ctx).pop();
                    } else {
                      Logx.ist(_TAG,
                          '🙃 select at least one lounge to share this photo to');
                    }
                  },
                ),
              ],
            );
          },
        );
      } else {
        Logx.est(_TAG, '🫤 something went wrong, please try again!');
      }
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
