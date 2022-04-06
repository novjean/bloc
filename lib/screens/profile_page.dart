import 'package:flutter/material.dart';

import '../db/entity/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // pull in the user
    // final User user = User();

    return Container(
      child: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
