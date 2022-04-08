import 'package:flutter/material.dart';

import '../db/entity/user.dart';
import '../db/experimental/user_preferences.dart';
import '../widgets/button_widget.dart';
import '../widgets/profile_widget.dart';
import '../widgets/ui/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  User user;

  EditProfilePage(this.user);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('BLOC'),),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    User user = widget.user;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: user.imageUrl,
          isEdit: true,
          onClicked: () async {
            
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Full Name',
          text: user.name,
          onChanged: (name) => user = user.copy(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Email',
          text: user.email,
          onChanged: (email) => user = user.copy(email: email),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'About',
          text: 'this is a test about, need to edit all this.',
          maxLines: 5,
          onChanged: (about) {},
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'Save',
          onClicked: () {
            UserPreferences.setUser(user);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

