import 'dart:io';

import 'package:bloc/db/entity/history_music.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../db/entity/user.dart' as blocUser;
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/number_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/profile_widget.dart';
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
    }
    super.initState();

    if(UserPreferences.isUserLoggedIn() && !kIsWeb){
      if(user.imageUrl.isEmpty){
        _uploadRandomPhoto(user);
      }
    }
  }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: _buildBody(context),
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

        // const SizedBox(height: 24),
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
            : const SizedBox()

        // const SizedBox(height: 48),
        // buildAbout(user),
        // const SizedBox(height: 48),
      ],
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
