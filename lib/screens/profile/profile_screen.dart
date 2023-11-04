import 'dart:io';

import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    User user = UserPreferences.myUser;
    if (UserPreferences.isUserLoggedIn()) {
      FirestoreHelper.pullHistoryMusicByUser(user.id)
          .then((res) {
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

      FirestoreHelper.pullPartyPhotosByUserId(UserPreferences.myUser.id).then((res) {
        if(res.docs.isNotEmpty){
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String,
                dynamic>;
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

    if(UserPreferences.isUserLoggedIn() && !kIsWeb){
      if(user.imageUrl.isEmpty){
        _uploadRandomPhoto(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: _isPartyPhotosLoading ? const LoadingWidget():
      _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    final user = UserPreferences.getUser();

    List<_PieData> pieData2 = [];

    if (showMusicHistory) {
      for (HistoryMusic historyMusic in mHistoryMusics) {
        _PieData pieData = _PieData(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  ? 'assets/profile_photos/12.png'
                                  : 'assets/profile_photos/1.png',
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
            'photos',
            textAlign: TextAlign.start,
            style: TextStyle(color: Constants.primary, fontSize: 20),
          ),
        ),

        mPartyPhotos.isNotEmpty ? _showPhotosGridView(mPartyPhotos): const SizedBox(),

        // NumbersWidget(),

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
                        textStyle: TextStyle(
                            color: Constants.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    legend: Legend(
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
                          dataLabelSettings: DataLabelSettings(
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
        )

        // const SizedBox(height: 48),
        // buildAbout(user),
        // const SizedBox(height: 48),
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
                _showPhotosDialog(context, index);
              },
              child: SizedBox(
                  height: 200,
                  width: 200,
                  child: kIsWeb? FadeInImage(
                    placeholder: const AssetImage('assets/icons/logo.png'),
                    image: NetworkImage(photo.imageThumbUrl.isNotEmpty? photo.imageThumbUrl:photo.imageUrl),
                    fit: BoxFit.cover,
                  ): CachedNetworkImage(
                    imageUrl: photo.imageThumbUrl.isNotEmpty? photo.imageThumbUrl:photo.imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) =>
                    const FadeInImage(
                      placeholder: AssetImage('assets/images/logo.png'),
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
              ),
            );
          }
        },
      ),
    );
  }
  
  int sIndex = 0;
  final CardSwiperController controller = CardSwiperController();

  _showPhotosDialog(BuildContext context, int index){
    sIndex = index;

    List<Container> cards = [];

    for(int i = index; i< mPartyPhotos.length; i++){
      PartyPhoto partyPhoto = mPartyPhotos[i];
      cards.add(
          Container(
            width: mq.width,
            height: mq.height,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Text(
                      partyPhoto.partyName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                    child: Text(
                      DateTimeUtils.getFormattedDate2(partyPhoto.partyDate),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  FadeInImage(
                    placeholder: const AssetImage('assets/images/logo_3x2.png'),
                    image: NetworkImage(partyPhoto.imageUrl),
                    fit: BoxFit.contain,
                  ),
                ]),
          ));
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
            height: mq.height,
            width: mq.width,
            child: Center(
              child:

              CardSwiper(
                controller: controller,
                cardsCount: cards.length,
                onSwipe: _onSwipe,
                numberOfCardsDisplayed: 1,
                duration: const Duration(milliseconds: 9),
                padding: const EdgeInsets.symmetric(vertical: 10),
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) => cards[index],
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
            // Padding(
            //   padding: const EdgeInsets.only(right: 5.0, left: 10),
            //   child: TextButton(
            //     child: const Text("🪂 share"),
            //     onPressed: () {
            //       Navigator.of(ctx).pop();
            //       _showShareOptionsDialog(context, mPartyPhotos[sIndex], sIndex);
            //     },
            //   ),
            // ),
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

                PartyPhoto partyPhoto = mPartyPhotos[sIndex];

                int fileNum = index + 1;
                String fileName = '${partyPhoto.partyName} $fileNum';
                FileUtils.saveNetworkImage(partyPhoto.imageUrl, fileName);

                FirestoreHelper.updatePartyPhotoDownloadCount(partyPhoto.id);

                Navigator.of(ctx).pop();

                if(UserPreferences.myUser.lastReviewTime < Timestamp.now().millisecondsSinceEpoch - (1 * DateTimeUtils.millisecondsWeek)){
                  if(!UserPreferences.myUser.isAppReviewed){
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

  bool _onSwipe(
      int previousIndex,
      int? currentIndex,
      CardSwiperDirection direction,
      ) {

    Logx.d(_TAG,
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );

    sIndex = sIndex + 1!;

    PartyPhoto partyPhoto = mPartyPhotos[sIndex];
    FirestoreHelper.updatePartyPhotoViewCount(partyPhoto.id);

    return true;
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

    int photoNum = NumberUtils.generateRandomNumber(1,5);
    if(user.gender == 'male'){
    } else {
      photoNum += 10;
    }
    assetFileName = 'assets/profile_photos/$photoNum.png';

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

}

class _PieData {
  _PieData(this.xData, this.yData, this.text);

  final String xData;
  final num yData;
  final String text;
}
