import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/screens/privacy_policy_screen.dart';
import 'package:bloc/screens/refund_policy_screen.dart';
import 'package:bloc/screens/terms_and_conditions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/entity/user.dart' as blocUser;
import '../helpers/firestorage_helper.dart';
import '../helpers/firestore_helper.dart';
import '../utils/logx.dart';
import '../widgets/ui/sized_listview_block.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  static const String _TAG = 'AccountScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bloc | account'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'privacy policy',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            }),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'refund policy',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RefundPolicyScreen()),
              );
            }),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'terms and conditions',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
              );
            }),
        const Divider(),
        const SizedBox(height: 5.0),
        GestureDetector(
            child: SizedListViewBlock(
              title: 'delete account',
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).errorColor,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("delete account"),
                    content: Text("deleting your account will delete your access and all your information on this site. are you sure you want to continue?"),
                    actions: [
                      TextButton(
                        child: Text("yes"),
                        onPressed: () async {
                          blocUser.User sUser = UserPreferences.myUser;

                          if(sUser.imageUrl.isNotEmpty) {
                            FirestorageHelper.deleteFile(sUser.imageUrl);
                          }

                          await FirebaseAuth.instance.signOut();
                          FirestoreHelper.deleteUser(sUser);
                          UserPreferences.resetUser();

                          Logx.i(_TAG, 'user account is deleted');

                          try {
                            User? user = FirebaseAuth.instance.currentUser;
                            user!.delete();
                          } on PlatformException catch (e, s) {
                            Logx.e(_TAG, e, s);
                          } on Exception catch (e, s) {
                            Logx.e(_TAG, e, s);
                          } catch (e) {
                            Logx.em(_TAG, 'account delete failed ' + e.toString());
                          }

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen(shouldTriggerSkip: false,)),
                          );
                        },
                      ),
                      TextButton(
                        child: const Text("no"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            }),
        const Divider(),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
