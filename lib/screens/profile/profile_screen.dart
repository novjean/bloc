import 'dart:io';

import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../db/entity/friend.dart';
import '../../db/entity/party_photo.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/entity/user.dart';
import '../../db/entity/user_photo.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/number_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/profile/pie_data.dart';
import '../../widgets/profile/user_friend_item.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/blurred_image.dart';
import '../../widgets/ui/button_widget.dart';
import 'profile_add_edit_register_page.dart';

import 'package:barcode_widget/barcode_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _TAG = 'ProfileScreen';

  bool _showQr = false;
  String _buttonText = 'qr code';

  List<HistoryMusic> mHistoryMusics = [];
  bool showMusicHistory = false;
  bool isMusicHistoryLoading = true;

  List<PartyPhoto> mPartyPhotos = [];
  var _isPartyPhotosLoading = true;

  @override
  void initState() {
    User user = UserPreferences.myUser;
    if (UserPreferences.isUserLoggedIn()) {
      FirestoreHelper.pullHistoryMusicByUser(user.id).then((res) {
        if (res.docs.isEmpty) {
          setState(() {
            showMusicHistory = false;
            isMusicHistoryLoading = false;
          });
        } else {
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final HistoryMusic historyMusic =
                Fresh.freshHistoryMusicMap(data, false);
            mHistoryMusics.add(historyMusic);
          }

          setState(() {
            showMusicHistory = true;
            isMusicHistoryLoading = false;
          });
        }
      });

      FirestoreHelper.pullPartyPhotosByUserId(UserPreferences.myUser.id)
          .then((res) {
        if (res.docs.isNotEmpty) {
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            PartyPhoto partyPhoto = Fresh.freshPartyPhotoMap(data, false);
            mPartyPhotos.add(partyPhoto);
          }

          setState(() {
            _isPartyPhotosLoading = false;
          });
        } else {
          setState(() {
            _isPartyPhotosLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _isPartyPhotosLoading = false;
      });
    }

    super.initState();

    if (UserPreferences.isUserLoggedIn() && !kIsWeb) {
      if (user.imageUrl.isEmpty) {
        _uploadRandomPhoto(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    final user = UserPreferences.getUser();

    List<PieData> pieData2 = [];

    if (showMusicHistory) {
      for (HistoryMusic historyMusic in mHistoryMusics) {
        PieData pieData = PieData(
            historyMusic.genre, historyMusic.count, historyMusic.genre);
        pieData2.add(pieData);
      }
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildName(user),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: buildPhotoQrToggleButton(),
                    ),
                  ],
                ),
              ),
              _showQr
                  ? Center(
                      child: BarcodeWidget(
                      color: Theme.of(context).primaryColorLight,
                      barcode: Barcode.qrCode(),
                      // Barcode type and settings
                      data: user.id,
                      // Content
                      width: 128,
                      height: 128,
                    ))
                  : user.imageUrl.isNotEmpty
                      ? ProfileWidget(
                          imagePath: user.imageUrl,
                          onClicked: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileAddEditRegisterPage(
                                        user: user,
                                        task: 'edit',
                                      )),
                            );
                            setState(() {});
                          },
                        )
                      : ClipOval(
                          child: Container(
                            width: 128.0,
                            height: 128.0,
                            color: Colors.blue,
                            // Optional background color for the circle
                            child: Image.asset(
                              user.gender == 'female'
                                  ? 'assets/profile_photos/12.jpeg'
                                  : 'assets/profile_photos/1.jpeg',
                              // Replace with your asset image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
          child: Text(
            'friends',
            textAlign: TextAlign.start,
            style: TextStyle(color: Constants.primary, fontSize: 20),
          ),
        ),
        _loadFriends(context),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
          child: Text(
            'photos',
            textAlign: TextAlign.start,
            style: TextStyle(color: Constants.primary, fontSize: 20),
          ),
        ),

        _isPartyPhotosLoading
            ? const SizedBox()
            : mPartyPhotos.isNotEmpty
                ? _showPhotosGridView(mPartyPhotos)
                : const Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 5),
                    child: Text(
                      'no photos to reminisce, just emptiness over here for a while.',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Constants.primary, fontSize: 16),
                    ),
                  ),

        // NumbersWidget(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Text(
            'history',
            textAlign: TextAlign.start,
            style: TextStyle(color: Constants.primary, fontSize: 20),
          ),
        ),
        showMusicHistory
            ? Center(
                child: SfCircularChart(
                    title: ChartTitle(
                        text: '',
                        textStyle: const TextStyle(
                            color: Constants.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    legend: const Legend(
                        isVisible: true,
                        textStyle: TextStyle(color: Constants.lightPrimary)),
                    series: <PieSeries<PieData, String>>[
                      PieSeries<PieData, String>(
                          explode: true,
                          explodeIndex: 0,
                          dataSource: pieData2,
                          xValueMapper: (PieData data, _) => data.xData,
                          yValueMapper: (PieData data, _) => data.yData,
                          dataLabelMapper: (PieData data, _) => data.text,
                          dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(color: Colors.white))),
                    ]),
              )
            : const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 5),
                child: Text(
                  'Events slippin\' by, you watchin\' distant. register for events and see your chart grow',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Constants.primary, fontSize: 16),
                ),
              ),
        const SizedBox(height: 36),
        Footer()
      ],
    );
  }

  _showPhotosGridView(List<PartyPhoto> photos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
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
                          placeholder:
                              const AssetImage('assets/icons/logo.png'),
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
              borderRadius: BorderRadius.all(Radius.circular(19.0))),
          contentPadding: const EdgeInsets.all(0.0),
          content: SizedBox(
            height: 400,
            width: double.maxFinite,
            child: Center(
              child: CarouselSlider(
                options: CarouselOptions(
                    height: 300,
                    initialPage: index,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 750),
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                        PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];
                        FirestoreHelper.updatePartyPhotoViewCount(partyPhoto.id);
                      });
                    }),
                items: partyPhotoUrls.map((item) {
                  return kIsWeb
                      ? Image.network(item, fit: BoxFit.fitWidth, width: mq.width)
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
            TextButton(
              child: const Text("❎ close"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("🗑️️ remove"),
              onPressed: () {
                // delete the user photo data
                PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];

                List<String> tags = partyPhoto.tags;
                tags.remove(UserPreferences.myUser.id);
                partyPhoto = partyPhoto.copyWith(tags: tags);
                FirestoreHelper.pushPartyPhoto(partyPhoto);

                FirestoreHelper.pullUserPhoto(
                        UserPreferences.myUser.id, partyPhoto.id)
                    .then((res) {
                  if (res.docs.isNotEmpty) {
                    DocumentSnapshot document = res.docs[0];
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    UserPhoto userPhoto = Fresh.freshUserPhotoMap(data, false);
                    userPhoto = userPhoto.copyWith(isConfirmed: false);
                    FirestoreHelper.pushUserPhoto(userPhoto);

                    Logx.ist(_TAG, 'your tag has been successfully removed!');
                    setState(() {});
                  } else {
                    Logx.em(_TAG, 'your tag for the photo could not be found');
                  }
                });
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("😎 set profile photo"),
              onPressed: () {
                PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];
                User user = UserPreferences.myUser;

                // check if photo already exists and in user bucket
                if (user.imageUrl.isNotEmpty &&
                    user.imageUrl.contains(FirestorageHelper.USER_IMAGES)) {
                  FirestorageHelper.deleteFile(user.imageUrl);
                }

                user = user.copyWith(imageUrl: partyPhoto.imageUrl);

                UserPreferences.setUser(user);
                FirestoreHelper.pushUser(user);

                setState(() {});

                Logx.ist(
                    _TAG, 'your profile photo has been successfully updated!');

                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("🪂 share"),
              onPressed: () {
                Navigator.of(ctx).pop();

                PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];

                int fileNum = index + 1;
                String fileName = '${partyPhoto.partyName} $fileNum';
                String shareText =
                    'hey. check out my photo at ${partyPhoto.partyName} and more at the official bloc app. Step into the moment. 📸'
                    '\n\n🍎 ios:\n${Constants.urlBlocAppStore} \n\n🤖 android:\n${Constants.urlBlocPlayStore} \n\n#blocCommunity 💛';

                FileUtils.sharePhoto(
                    partyPhoto.id, partyPhoto.imageUrl, fileName, shareText);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text(
                "💕 save",
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
                    DialogUtils.showReviewAppDialog(context);
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

  Widget buildName(blocUser.User user) => Column(
        children: [
          Text(
            user.name.isNotEmpty
                ? '${user.name.toLowerCase()} ${user.surname.toLowerCase()}'
                : 'bloc star',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 5),
          // Text(
          //   user.email.isNotEmpty ? user.email : '',
          //   style: TextStyle(color: Theme.of(context).primaryColorLight),
          // )
        ],
      );

  Widget buildPhotoQrToggleButton() => Center(
        child: ButtonWidget(
          text: _buttonText,
          onClicked: () {
            setState(() {
              _showQr = !_showQr;
              if (!_showQr) {
                _buttonText = 'qr code';
              } else {
                _buttonText = 'photo';
              }
            });
          },
        ),
      );

  void _uploadRandomPhoto(blocUser.User user) async {
    String assetFileName = '';

    int photoNum = NumberUtils.getRandomNumber(1, 5);
    if (user.gender == 'male') {
    } else {
      photoNum += 10;
    }
    assetFileName = 'assets/profile_photos/$photoNum.jpeg';

    File imageFile = await FileUtils.getAssetImageAsFile(assetFileName);
    String imageUrl = await FirestorageHelper.uploadFile(
        FirestorageHelper.USER_IMAGES,
        StringUtils.getRandomString(28),
        imageFile);

    user = user.copyWith(imageUrl: imageUrl);
    FirestoreHelper.pushUser(user);
    UserPreferences.setUser(user);

    Logx.i(_TAG, 'user default photo added.');
  }

  _loadFriends(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUserFriends(UserPreferences.myUser.id),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                List<Friend> friends = [];

                try {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final Friend friend = Fresh.freshFriendMap(map, false);

                    friends.add(friend);
                  }

                  if (friends.isNotEmpty) {
                    return _showFriends(context, friends);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 5),
                      child: DelayedDisplay(
                        delay: Duration(seconds: 1),
                        child: Text(
                          'you are rolling solo in this story, no side characters yet!',
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(color: Constants.primary, fontSize: 16),
                        ),
                      ),
                    );
                  }
                } on Exception catch (e, s) {
                  Logx.e(_TAG, e, s);
                } catch (e) {
                  Logx.em(_TAG, 'error loading friends : $e');
                }
              }
          }
          return const LoadingWidget();
        });
  }

  _showFriends(BuildContext context, List<Friend> friends) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
          itemCount: friends.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: false,
          itemBuilder: (ctx, index) {
            Logx.d(_TAG, 'friends length: ${friends.length}, index $index');

            Friend friend = friends[index];

            return UserFriendItem(
              friend: friend,
            );
          }),
    );
  }
}
