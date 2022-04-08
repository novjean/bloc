import 'package:flutter/material.dart';

import '../db/entity/user.dart';
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
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: widget.user.imageUrl,
          isEdit: true,
          onClicked: () async {
            
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Full Name',
          text: widget.user.name,
          onChanged: (name) {},
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Email',
          text: widget.user.email,
          onChanged: (email) {

          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'About',
          text: 'this is a test about, need to edit all this.',
          maxLines: 5,
          onChanged: (about) {},
        ),
      ],
    );
  }
}

