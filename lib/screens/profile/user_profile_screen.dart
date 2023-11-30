import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/helpers/firestore_helper.dart';
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
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
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
  String _btnFollowText = '📵 ghost';

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
                _btnFriendText = '☠️ unfriend';
                isFollowing = mFriend.isFollowing;

              });
            } else {
              setState(() {
                isFriend = false;
                _btnFriendText = '🤍 friend';
                isFollowing = false;
              });
            }
          });
        }
      } else {
        // profile not found, navigate to home
        Logx.ist(_TAG, 'unfortunately, the profile could not be found');
        GoRouter.of(context).pushNamed(RouteConstants.landingRouteName);
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
          icon: const Icon(Icons.arrow_back_ios_rounded),
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
    List<_PieData> pieData2 = [];

    if (showMusicHistory) {
      for (HistoryMusic historyMusic in mHistoryMusics) {
        _PieData pieData = _PieData(
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
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 15.0),
                child:

                Text(
                  mUser.name.isNotEmpty
                      ? mUser.name.toLowerCase()
                      : '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              mUser.imageUrl.isNotEmpty
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
                        ? 'assets/profile_photos/12.png'
                        : 'assets/profile_photos/1.png',
                    // Replace with your asset image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:15.0, right: 10),
                child:

                Text(
                  mUser.name.isNotEmpty
                      ? mUser.surname.toLowerCase()
                      : '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Theme.of(context).primaryColor),
                ),

                // buildLastName(mUser),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        UserPreferences.isUserLoggedIn()?
        Row(
          mainAxisAlignment: isFriend? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
          children: [
            isFriend ? buildFollowUnfollowButton(): const SizedBox(),
            buildFriendUnfriendToggleButton(),
          ],
        ) : const SizedBox(),
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
            :  Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 5),
          child: Text(
            '${mUser.name.toLowerCase()} hasn\'t been tagged on any photos yet!',
            textAlign: TextAlign.start,
            style:
            const TextStyle(color: Constants.primary, fontSize: 16),
          ),
        ),
        const Divider(),
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
              series: <PieSeries<_PieData, String>>[
                PieSeries<_PieData, String>(
                    explode: true,
                    explodeIndex: 0,
                    dataSource: pieData2,
                    xValueMapper: (_PieData data, _) => data.xData,
                    yValueMapper: (_PieData data, _) => data.yData,
                    dataLabelMapper: (_PieData data, _) => data.text,
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
        )
      ],
    );
  }

  Widget buildFriendUnfriendToggleButton() {
    return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () {
            isFriend = !isFriend;

            if (isFriend) {
              // become friends
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
                '${UserPreferences.myUser.name} ${UserPreferences.myUser.surname} has added you as their friend!'
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
                _btnFriendText = '🤍 friend';
              } else {
                _btnFriendText = '☠️ unfriend';
              }
              mFriend;
            });
          },
          child: Text(
            _btnFriendText,
            style: TextStyle(fontSize: 18,
              color: isFriend? Colors.black: Colors.white
            ),
          ),
        ));
  }

  Widget buildFollowUnfollowButton() {
    return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: () {
            isFollowing = !isFollowing;

            if (isFollowing) {
              mFriend = mFriend.copyWith(isFollowing: true);
              FirestoreHelper.pushFriend(mFriend);

              setState(() {
                isFollowing = true;
                _btnFollowText = '📵 ghost';
              });
            } else {
              mFriend = mFriend.copyWith(isFollowing: false);
              FirestoreHelper.pushFriend(mFriend);

              setState(() {
                isFollowing = false;
                _btnFollowText = '🔗 link';
              });
            }
          },
          child: Text(
            _btnFollowText,
            style: TextStyle(fontSize: 18,
              color: isFollowing? Colors.green : Colors.red
            ),
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
                DialogUtils.showDownloadAppDialog(context);
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
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(0.0),
          content: SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CarouselSlider(
                options: CarouselOptions(
                    initialPage: index,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                    const Duration(milliseconds: 750),
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      _currentIndex = index;
                      Logx.d(_TAG, 'index is $_currentIndex');

                      PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];
                      FirestoreHelper.updatePartyPhotoViewCount(partyPhoto.id);

                      setState(() {});
                    }
                  // aspectRatio: 1.0,
                ),
                items: partyPhotoUrls.map((item) {
                  return kIsWeb
                      ? Image.network(item, fit: BoxFit.cover, width: MediaQuery.of(context).size.width)
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

                  PartyPhoto partyPhoto = mPartyPhotos[_currentIndex];

                  int fileNum = index + 1;
                  String fileName = '${partyPhoto.partyName} $fileNum';
                  String shareText =
                      'hey. check out this photo and more of ${partyPhoto.partyName} at the official bloc app. Step into the moment. 📸 \n\n🌏 https://bloc.bar/#/\n📱 https://bloc.bar/app_store.html\n\n#blocCommunity ❤️‍🔥';

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

  Widget buildAbout(blocUser.User user) => Container(
    padding: EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          '',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ],
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

class _PieData {
  _PieData(this.xData, this.yData, this.text);

  final String xData;
  final num yData;
  final String text;
}
