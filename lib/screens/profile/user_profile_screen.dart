import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../api/apis.dart';
import '../../db/entity/friend.dart';
import '../../db/entity/party_photo.dart';
import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../widgets/footer.dart';
import '../../widgets/profile/pie_data.dart';
import '../../widgets/profile/user_friend_item.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/blurred_image.dart';
import '../../widgets/ui/button_widget.dart';

class UserProfileScreen extends StatefulWidget {
  String username;

  UserProfileScreen({key, required this.username}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const String _TAG = 'UserProfileScreen';

  String _btnFriendText = 'friend';

  List<HistoryMusic> mHistoryMusics = [];
  bool showMusicHistory = false;
  bool isMusicHistoryLoading = true;

  List<PartyPhoto> mPartyPhotos = [];
  var _isPartyPhotosLoading = true;

  blocUser.User mUser = Dummy.getDummyUser();
  var _isUserLoading = true;

  Friend mFriend = Dummy.getDummyFriend();
  bool isFriend = false;
  bool isFollowing = true;

  List<Friend> mFriends = [];

  int _currentIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    FirestoreHelper.pullUserByUsername(widget.username).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mUser = Fresh.freshUserMap(data, false);

        setState(() {
          _isUserLoading = false;
        });

        FirestoreHelper.pullHistoryMusicByUser(mUser.id).then((res) {
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

        FirestoreHelper.pullPartyPhotosByUserId(mUser.id).then((res) {
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

        if (UserPreferences.isUserLoggedIn()) {
          FirestoreHelper.pullFriend(UserPreferences.myUser.id, mUser.id)
              .then((res) {
            if (res.docs.isNotEmpty) {
              DocumentSnapshot document = res.docs[0];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              mFriend = Fresh.freshFriendMap(data, false);

              setState(() {
                isFriend = true;
                _btnFriendText = 'unfriend';
                isFollowing = mFriend.isFollowing;
              });
            } else {
              setState(() {
                isFriend = false;
                _btnFriendText = 'friend';
                isFollowing = false;
              });
            }
          });
        }
      } else {
        // profile not found, navigate to home
        Logx.ist(_TAG, '🤯 the profile could not be found!');
        GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: ''),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: _isUserLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    List<PieData> pieData2 = [];

    if (showMusicHistory) {
      for (HistoryMusic historyMusic in mHistoryMusics) {
        PieData pieData = PieData(
            historyMusic.genre, historyMusic.count, historyMusic.genre);
        pieData2.add(pieData);
      }
    }

    return ListView(
      // shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 15.0),
                  child: Text(
                    mUser.name.toLowerCase(),
                    maxLines: 3,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Constants.primary),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: mUser.imageUrl.isNotEmpty
                    ? ProfileWidget(
                        isEdit: false,
                        imagePath: mUser.imageUrl,
                        showEditIcon: false,
                        onClicked: () {},
                      )
                    : ClipOval(
                        child: Container(
                          width: 128.0,
                          height: 128.0,
                          color: Constants.primary,
                          // Optional background color for the circle
                          child: Image.asset(
                            mUser.gender == 'female'
                                ? 'assets/profile_photos/12.jpeg'
                                : 'assets/profile_photos/1.jpeg',
                            // Replace with your asset image path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 10),
                  child: Text(
                    mUser.surname.toLowerCase(),
                    maxLines: 3,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Constants.primary),
                  ),

                  // buildLastName(mUser),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        UserPreferences.isUserLoggedIn()
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: buildFriendUnfriendToggleButton(),
                  ),
                  isFriend
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: buildFollowGhostIconButton(),
                        )
                      : const SizedBox(),
                  const Spacer(),
                  mUser.instagramLink.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: buildInstagramButton(),
                        )
                      : const SizedBox(),
                ],
              )
            : const SizedBox(),
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
                : Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 5),
                    child: Text(
                      '${mUser.name.toLowerCase()} hasn\'t been tagged on any photos yet!',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Constants.primary, fontSize: 16),
                    ),
                  ),
        const SizedBox(height: 24,),
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
            : Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 5),
                child: Text(
                  '${mUser.name.toLowerCase()} hasn\'t pulled up to any events yet!',
                  textAlign: TextAlign.start,
                  style:
                      const TextStyle(color: Constants.primary, fontSize: 16),
                ),
              ),
        const SizedBox(height: 36),
        Footer()
      ],
    );
  }

  Widget buildInstagramButton() {
    return Center(
        child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        String link = '';
        if(!mUser.instagramLink.contains('instagram.com')){
          link = 'https://www.instagram.com/${mUser.instagramLink.trim()}/';
        } else {
          link = mUser.instagramLink;
        }
        Uri uri = Uri.parse(link);
        NetworkUtils.launchInBrowser(uri);
      },
      label: const Text(
        'instagram',
        style: TextStyle(fontSize: 18, color: Constants.darkPrimary),
      ),
      icon: const Icon(
        Icons.local_fire_department,
        color: Constants.darkPrimary,
      ),
    ));
  }

  Widget buildFriendUnfriendToggleButton() {
    return Center(
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {
              isFriend = !isFriend;

              if (isFriend) {
                Friend friend = Dummy.getDummyFriend();
                friend = friend.copyWith(
                  userId: UserPreferences.myUser.id,
                  friendUserId: mUser.id,
                  isFollowing: true,
                );
                FirestoreHelper.pushFriend(friend);

                //should send a friend notification
                if (mUser.fcmToken.isNotEmpty) {
                  String title = '🤍 new friend alert';
                  String message =
                      '${UserPreferences.myUser.name} ${UserPreferences.myUser.surname} has added you as a friend 🤗! Check them out!'
                          .toLowerCase();

                  Apis.sendPushNotification(mUser.fcmToken, title, message);
                }

                setState(() {
                  mFriend = friend;
                  isFollowing = true;
                });
              } else {
                FirestoreHelper.deleteFriend(mFriend.id);
              }

              setState(() {
                if (!isFriend) {
                  _btnFriendText = 'friend';
                } else {
                  _btnFriendText = 'unfriend';
                }
                mFriend;
              });
            },
            label: Text(
              _btnFriendText,
              style:
                  const TextStyle(fontSize: 17, color: Constants.darkPrimary),
            ),
            icon: Icon(
              isFriend
                  ? Icons.person_remove_alt_1_rounded
                  : Icons.person_add_alt_1_rounded,
              color: Constants.darkPrimary,
            )));
  }

  Widget buildFollowGhostIconButton() {
    return Center(
        child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Constants.primary, // Set the color of the circle border
          width: 2.0, // Set the width of the circle border
        ),
      ),
      child: IconButton(
        color: Constants.primary,
        icon: Icon(
          isFollowing
              ? Icons.notifications_active_rounded
              : Icons.notifications_outlined,
          size: 22.0,
        ),
        onPressed: () {
          isFollowing = !isFollowing;

          if (isFollowing) {
            mFriend = mFriend.copyWith(isFollowing: true);
            FirestoreHelper.pushFriend(mFriend);

            Logx.ist(_TAG, '😍 you are now following ${mUser.name}');

            setState(() {
              isFollowing = true;
            });
          } else {
            mFriend = mFriend.copyWith(isFollowing: false);
            FirestoreHelper.pushFriend(mFriend);

            Logx.ist(_TAG, '😑 you have unfollowed ${mUser.name}');

            setState(() {
              isFollowing = false;
            });
          }
        },
      ),
    ));
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
                        FirestoreHelper.updatePartyPhotoViewCount(
                            partyPhoto.id);
                      });
                    }),
                items: partyPhotoUrls.map((item) {
                  return kIsWeb
                      ? Image.network(item,
                          fit: BoxFit.fitWidth,
                          width: MediaQuery.of(context).size.width)
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
            UserPreferences.myUser.clearanceLevel >= Constants.ADMIN_LEVEL
                ? Padding(
                    padding: const EdgeInsets.only(right: 5.0, left: 10),
                    child: TextButton(
                      child: const Text("😎 set profile photo"),
                      onPressed: () async {
                        PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];
                        if (mUser.imageUrl.isNotEmpty &&
                            mUser.imageUrl
                                .contains(FirestorageHelper.USER_IMAGES)) {
                          await FirestorageHelper.deleteFile(mUser.imageUrl);
                        }

                        mUser = mUser.copyWith(imageUrl: partyPhoto.imageUrl);
                        FirestoreHelper.pushUser(mUser);

                        setState(() {});
                        Logx.ist(_TAG,
                            '😻 ${mUser.name}\'s profile photo has been successfully updated!');
                      },
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(right: 5.0, left: 10),
              child: TextButton(
                child: const Text("🪂 share"),
                onPressed: () {
                  Navigator.of(ctx).pop();

                  PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];

                  int fileNum = index + 1;
                  String fileName = '${partyPhoto.partyName} $fileNum';
                  String shareText =
                      'hey. check out this photo and more of ${partyPhoto.partyName} at the official bloc app. Step into the moment. 📸'
                      '\n\n🍎 ios:\n${Constants.urlBlocAppStore} \n\n🤖 android:\n${Constants.urlBlocPlayStore} \\n\n#blocCommunity 💛';

                  FileUtils.sharePhoto(
                      partyPhoto.id, partyPhoto.imageUrl, fileName, shareText);
                },
              ),
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

  Widget buildFollowButton() => Center(
        child: ButtonWidget(
          text: _btnFriendText,
          onClicked: () {},
        ),
      );

  _loadFriends(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUserFriends(mUser.id),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                mFriends = [];

                try {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot document = snapshot.data!.docs[i];
                    Map<String, dynamic> map =
                        document.data()! as Map<String, dynamic>;
                    final Friend friend = Fresh.freshFriendMap(map, false);

                    mFriends.add(friend);
                  }

                  if (mFriends.isNotEmpty) {
                    return _showFriends(context);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 5),
                      child: DelayedDisplay(
                        delay: const Duration(seconds: 1),
                        child: Text(
                          '${mUser.name.toLowerCase()} is rolling solo in this story, no side characters yet!',
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              color: Constants.primary, fontSize: 16),
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

  _showFriends(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
          itemCount: mFriends.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (ctx, index) {
            Friend friend = mFriends[index];

            return UserFriendItem(
              friend: friend,
            );
          }),
    );
  }
}
