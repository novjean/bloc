// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../db/entity/user.dart' as blocUser;
import '../db/experimental/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../utils/user_utils.dart';
import '../widgets/profile/numbers_widget.dart';
import '../widgets/profile_widget.dart';
import '../widgets/ui/button_widget.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTestBody(context),

      // body: _buildBody(context),
    );
  }

  _buildTestBody(BuildContext context) {
    final user = UserPreferences.getUser();

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: user.imageUrl,
          onClicked: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EditProfilePage(user)),
            );
            setState(() {});
          },
        ),
        const SizedBox(height: 24),
        buildName(user),
        const SizedBox(height: 24),
        Center(child: buildUpgradeButton()),
        const SizedBox(height: 24),
        NumbersWidget(),
        const SizedBox(height: 48),
        buildAbout(user),
      ],
    );
  }

  _buildBody(BuildContext context) {
    final fbUser = FirebaseAuth.instance.currentUser;
    CollectionReference users = FirestoreHelper.getUsersCollection();

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(fbUser!.uid).get(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text("user loading went wrong");
          }
          if (snapshot.hasData && !snapshot.data!.exists) {
            logger.e('document does not exist');
            // return const AuthScreen();
            // return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            final blocUser.User user = UserUtils.getUser(data);

            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 15),
                ProfileWidget(
                  imagePath: user.imageUrl,
                  onClicked: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EditProfilePage(user)),
                    );
                  },
                ),
                const SizedBox(height: 24),
                buildName(user),
                const SizedBox(height: 24),
                Center(child: buildUpgradeButton()),
                const SizedBox(height: 24),
                NumbersWidget(),
                const SizedBox(height: 48),
                buildAbout(user),
              ],
            );
          }
          return Text('Loading profile page...');
        });
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

  Widget buildUpgradeButton() => ButtonWidget(
    text: 'Contact',
    onClicked: () {},
  );

  Widget buildAbout(blocUser.User user) => Container(
    padding: EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Baby girl, I lovuuu!!!',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ],
    ),
  );
}


