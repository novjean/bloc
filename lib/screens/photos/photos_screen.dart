import 'package:bloc/db/entity/party_photo.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/utils/dialog_utils.dart';
import 'package:bloc/widgets/ui/blurred_image.dart';
import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../db/entity/ad.dart';
import '../../db/entity/lounge.dart';
import '../../db/entity/lounge_chat.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../widgets/footer.dart';
import '../../widgets/photo/party_photo_item.dart';
import '../../widgets/store_badge_item.dart';
import '../../widgets/ui/loading_widget.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static const String _TAG = 'PhotosScreen';

  List<PartyPhoto> mPartyPhotos = [];
  var _isPartyPhotosLoading = true;
  bool _showList = true;

  List<Lounge> sLounges = [];
  String photoChatMessage = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    FirestoreHelper.pullPartyPhotos().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final PartyPhoto partyPhoto = Fresh.freshPartyPhotoMap(data, false);

          if(UserPreferences.getUserBlocs().contains(partyPhoto.blocServiceId)){
            mPartyPhotos.add(partyPhoto);
          }
        }

        setState(() {
          _isPartyPhotosLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      floatingActionButton: _showToggleViewButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      resizeToAvoidBottomInset: false,
      body: _isPartyPhotosLoading
          ? const LoadingWidget()
          : (_showList
              ? _showPhotosListView(mPartyPhotos)
              : _showPhotosGridView(mPartyPhotos)),
    );
  }

  _showPhotosGridView(List<PartyPhoto> photos) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        PartyPhoto photo = photos[index];

        if (kIsWeb) {
          return GestureDetector(
            onTap: () {
              DialogUtils.showDownloadAppDialog(context, DialogUtils.downloadPhotos);
              },
            child: SizedBox(
                height: 200,
                child: BlurredImage(
                  imageUrl: photo.imageUrl,
                  blurLevel: 3,
                )),
          );
        } else {
          return GestureDetector(
            onTap: () {
              _showPhotosDialog(index);
            },
            child: SizedBox(
                height: 200,
                width: 200,
                child: kIsWeb
                    ? FadeInImage(
                        placeholder: const AssetImage('assets/icons/logo.png'),
                        image: NetworkImage(photo.imageThumbUrl.isNotEmpty
                            ? photo.imageThumbUrl
                            : photo.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: photo.imageThumbUrl.isNotEmpty
                            ? photo.imageThumbUrl
                            : photo.imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => const FadeInImage(
                          placeholder: AssetImage('assets/images/logo.png'),
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )),
          );
        }
      },
    );
  }

  _showPhotosListView(List<PartyPhoto> photos) {
    return ListView.builder(
      itemCount: photos.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        PartyPhoto partyPhoto = photos[index];

        if (!kIsWeb) {
          FirestoreHelper.updatePartyPhotoViewCount(partyPhoto.id);
        }

        if (index == photos.length - 1) {
          return Column(
            children: [
              PartyPhotoItem(
                partyPhoto: partyPhoto,
                index: index,
              ),
              const SizedBox(height: 15.0),
              kIsWeb ? const StoreBadgeItem() : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              Footer()
            ],
          );
        } else {
          return PartyPhotoItem(
            partyPhoto: partyPhoto,
            index: index,
          );
        }
      },
    );
  }

  _showToggleViewButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _showList = !_showList;
        });
      },
      backgroundColor: Constants.primary,
      tooltip: 'toggle view',
      elevation: 5,
      splashColor: Colors.grey,
      child: Icon(
        _showList ? Icons.grid_on_rounded : Icons.list_rounded,
        color: Colors.black,
        size: 29,
      ),
    );
  }

  int _currentIndex = 0;

  _showPhotosDialog(int index) {
    List<String> partyPhotoUrls = [];

    _currentIndex = index;

    for (PartyPhoto partyPhoto in mPartyPhotos) {
      partyPhotoUrls.add(partyPhoto.imageUrl);
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(1.0),
          content: SizedBox(
            height: 400,
            width: double.maxFinite,
            child: Center(
              child: CarouselSlider(
                options: CarouselOptions(
                    height: 300,
                    initialPage: index,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 750),
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                        PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];
                        FirestoreHelper.updatePartyPhotoViewCount(
                            partyPhoto.id);
                      });
                    }
                    // aspectRatio: 1.0,
                    ),
                items: partyPhotoUrls.map((item) {
                  return kIsWeb
                      ? Image.network(item,
                          fit: BoxFit.fitWidth, width: MediaQuery.of(context).size.width)
                      : CachedNetworkImage(
                          imageUrl: item,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => const FadeInImage(
                            placeholder: AssetImage('assets/images/logo.png'),
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                }).toList(),
              ),
            ),
          ),
          actions: [
            UserPreferences.myUser.clearanceLevel >= Constants.ADMIN_LEVEL
                ? TextButton(
                    child: const Text("advertise"),
                    onPressed: () {
                      Ad ad = Dummy.getDummyAd(
                          mPartyPhotos[_currentIndex].blocServiceId);
                      ad = ad.copyWith(
                          imageUrl: mPartyPhotos[_currentIndex].imageUrl,
                          isActive: true);

                      Navigator.of(ctx).pop();
                      _showAdDialog(context, ad);
                    },
                  )
                : const SizedBox(),
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0, left: 10),
              child: TextButton(
                child: const Text("🪂 share"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showShareOptionsDialog(
                      context, mPartyPhotos[_currentIndex], _currentIndex);
                },
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text(
                "💕 save to gallery",
                style: TextStyle(color: Constants.primary),
              ),
              onPressed: () {
                Logx.ist(_TAG, '🍄 saving to gallery...');

                PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];

                int fileNum = index + 1;
                String fileName = '${partyPhoto.partyName} $fileNum';
                FileUtils.saveNetworkImage(partyPhoto.imageUrl, fileName);

                FirestoreHelper.updatePartyPhotoDownloadCount(partyPhoto.id);

                Navigator.of(ctx).pop();

                if (UserPreferences.myUser.lastReviewTime <
                    Timestamp.now().millisecondsSinceEpoch -
                        (1 * DateTimeUtils.millisecondsWeek)) {
                  if (!UserPreferences.myUser.isAppReviewed) {
                    _showReviewAppDialog(context);
                  } else {
                    //todo: might need to implement challenge logic here
                    Logx.i(_TAG, 'app is reviewed, so nothing to do for now');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  _showReviewAppDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '🍭 review our app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(
                'Behind bloc, there\'s a small but dedicated team pouring their hearts into it. Will you be our champion by leaving a review? Together, we\'ll build the best community app out there!'
                    .toLowerCase()),
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
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.lightPrimary),
                ),
                child: const Text(
                  '🧸 already reviewed',
                ),
                onPressed: () async {
                  User user = UserPreferences.myUser;
                  user = user.copyWith(
                      isAppReviewed: true,
                      lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                  FirestoreHelper.pushUser(user);

                  Logx.ist(_TAG, '🃏 thank you for already reviewing us');

                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Constants.darkPrimary),
                ),
                child: const Text('🌟 review us',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  bool isAvailable = await inAppReview.isAvailable();

                  if (isAvailable) {
                    inAppReview.requestReview();
                  } else {
                    inAppReview.openStoreListing(
                        appStoreId: Constants.blocAppStoreId);
                  }

                  User user = UserPreferences.myUser;
                  user = user.copyWith(
                      isAppReviewed: true,
                      lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                  // UserPreferences.setUser(user);
                  FirestoreHelper.pushUser(user);

                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

  _showShareOptionsDialog(
      BuildContext context, PartyPhoto partyPhoto, int index) {
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
                                        _showLoungeChatDialog(
                                            context, partyPhoto);
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

                                        int fileNum = index + 1;
                                        String fileName =
                                            '${partyPhoto.partyName} $fileNum';
                                        String shareText =
                                            'hey. check out this photo and more of ${partyPhoto.partyName} at the official bloc app. Step into the moment. 📸 '
                                            '\n\n🍎 ios:\n${Constants.urlBlocAppStore} \n\n🤖 android:\n${Constants.urlBlocPlayStore} \n\n#blocCommunity 💛';

                                        FileUtils.sharePhoto(
                                            partyPhoto.id,
                                            partyPhoto.imageUrl,
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

  _showLoungeChatDialog(BuildContext context, PartyPhoto partyPhoto) {
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
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: Text(
                          'share photo to lounge',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      Center(
                          child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/logo_3x2.png'),
                          image: NetworkImage(
                              partyPhoto.imageThumbUrl.isNotEmpty
                                  ? partyPhoto.imageThumbUrl
                                  : partyPhoto.imageUrl),
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Constants.darkPrimary),
                  ),
                  child: const Text(
                    "💌 send",
                    style: TextStyle(color: Constants.primary),
                  ),
                  onPressed: () {
                    if (sLounges.isNotEmpty) {
                      LoungeChat chat = Dummy.getDummyLoungeChat();
                      for (Lounge lounge in sLounges) {
                        chat = chat.copyWith(
                          imageUrl: partyPhoto.imageUrl,
                          message: photoChatMessage,
                          type: FirestoreHelper.CHAT_TYPE_IMAGE,
                          loungeId: lounge.id,
                          loungeName: lounge.name,
                        );

                        FirestoreHelper.pushLoungeChat(chat);
                        FirestoreHelper.updateLoungeLastChat(
                            lounge.id, '📸 $photoChatMessage', chat.time);
                      }

                      Logx.ist(_TAG, 'photo has been successfully shared 💝');
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

  _showAdDialog(BuildContext context, Ad ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/logo_3x2.png'),
                    image: NetworkImage(ad.imageUrl),
                    fit: BoxFit.contain,
                  ),
                )),
                TextFieldWidget(
                  text: ad.title,
                  onChanged: (text) {
                    ad = ad.copyWith(title: text);
                  },
                  label: 'title',
                ),
                TextFieldWidget(
                  text: ad.message,
                  maxLines: 5,
                  onChanged: (text) {
                    ad = ad.copyWith(message: text);
                  },
                  label: 'message',
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text('💎 post ad',
                  style: TextStyle(color: Constants.primary)),
              onPressed: () async {
                FirestoreHelper.pushAd(ad);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
