import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/button_widget.dart';
import 'profile_add_edit_register_page.dart';

import 'package:barcode_widget/barcode_widget.dart';

class ProfilePage extends StatefulWidget {

  ProfilePage({key}):super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var logger = Logger();
  bool _showQr = false;
  String _buttonText = 'qr code';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    final user = UserPreferences.getUser();

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        _showQr ?
        Center(
            child: BarcodeWidget(
              barcode: Barcode.qrCode(), // Barcode type and settings
              data: user.id, // Content
              width: 128,
              height: 128,
            )
        ):
        ProfileWidget(
          imagePath: user.imageUrl,
          onClicked: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileAddEditRegisterPage(user: user, task: 'edit',)),
            );
            setState(() {});
          },
        ),
        const SizedBox(height: 24),
        buildName(user),
        const SizedBox(height: 24),
        buildContactButton(),
        // const SizedBox(height: 24),
        // NumbersWidget(),
        const SizedBox(height: 48),
        // buildAbout(user),
        // const SizedBox(height: 48),

      ],
    );
  }

  Widget buildName(blocUser.User user) => Column(
    children: [
      Text(
        user.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        user.email,
        style: TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildContactButton() => Center(
    child: ButtonWidget(
      text: _buttonText,
      onClicked: () {
        setState(() {
          _showQr = !_showQr;
          if(!_showQr){
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


