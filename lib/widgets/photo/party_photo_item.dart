import 'dart:ui';

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/file_utils.dart';
import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:flutter/material.dart';

import '../../db/entity/party_photo.dart';
import '../../main.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../utils/network_utils.dart';
import '../ui/blurred_image.dart';
import '../ui/dark_button_widget.dart';

class PartyPhotoItem extends StatefulWidget {
  PartyPhoto partyPhoto;
  int index;

  PartyPhotoItem({
    Key? key,
    required this.partyPhoto,
    required this.index
  }) : super(key: key);

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
            padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 2, top: 0),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                kIsWeb
                    ? Stack(alignment: Alignment.center, children: [
                        BlurredImage(
                          imageUrl: widget.partyPhoto.imageUrl,
                          blurLevel: 5,
                        ),
                        Positioned(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'your view, your way. download our app to see and save.',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
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
                                      padding: const EdgeInsets.only(left: 20.0),
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
                      isLoved
                          ? Text(
                              widget.partyPhoto.likers.length.toString(),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: InkWell(
                            onTap: () {
                              if (widget.partyPhoto.likers.isEmpty) {
                                widget.partyPhoto.likers
                                    .add(UserPreferences.myUser.id);
                                FirestoreHelper.pushPartyPhoto(
                                    widget.partyPhoto);
                              } else {
                                if (!isLoved) {
                                  widget.partyPhoto.likers
                                      .add(UserPreferences.myUser.id);
                                  FirestoreHelper.pushPartyPhoto(
                                      widget.partyPhoto);
                                } else {
                                  Logx.ist(_TAG,
                                      'love once shared cannot be taken back 😘');
                                }
                              }
                            },
                            child: isLoved
                                ? Icon(Icons.favorite, size: 24.0)
                                : Icon(Icons.favorite_border, size: 24.0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: InkWell(
                          onTap: () {
                            if (kIsWeb) {
                              _showDownloadAppDialog(context);
                            } else {
                              Logx.ist(_TAG, 'downloading');
                              int fileNum = widget.index+1;
                              String fileName = '${widget.partyPhoto.partyName} $fileNum';

                              FileUtils.saveNetworkImage(
                                  widget.partyPhoto.imageUrl, fileName);

                              int count = widget.partyPhoto.downloadCount + 1;
                              widget.partyPhoto = widget.partyPhoto
                                  .copyWith(downloadCount: count);
                              FirestoreHelper.pushPartyPhoto(widget.partyPhoto);
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
            title: Text(
              'bloc app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: const Text(
                "ready, set, download delight! bloc app in hand, memories at hand. download our app in order to save photos to your gallery."),
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
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Constants.darkPrimary), // Set your desired background color
                ),
                child: Text('🤖 android',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final uri = Uri.parse(ChallengeUtils.urlBlocPlayStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Constants.darkPrimary), // Set your desired background color
                ),
                child:
                    Text('🍎 ios', style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final uri = Uri.parse(ChallengeUtils.urlBlocAppStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
            ],
          );
        });
  }
}
