import 'package:flutter/material.dart';

import '../db/entity/user.dart';
import '../widgets/profile_widget.dart';
import '../widgets/ui/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User user = User(userId:'userId',
      username:'username',
      email:'email',
      imageUrl:'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80',
      clearanceLevel:9,
      name:'Nova K');

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('BLOC'),),
    body: ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: user.imageUrl,
          isEdit: true,
          onClicked: () async {},
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Full Name',
          text: user.name,
          onChanged: (name) {},
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Email',
          text: user.email,
          onChanged: (email) {},
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'About',
          text: 'this is a test about, need to edit all this.',
          maxLines: 5,
          onChanged: (about) {},
        ),
      ],
    ),
  );
}