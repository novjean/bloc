import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/db/entity/user_level.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:bloc/screens/manager/users/user_add_edit_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/user.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../widgets/manager/user_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class ManageUsersScreen extends StatefulWidget {
  ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _selectedType = 'customer';
  List<UserLevel> mUserLevels = [];
  var _isUserLevelsLoading = true;

  @override
  void initState() {
    super.initState();

    // lets pull in user levels
    FirestoreHelper.pullUserLevels(UserPreferences.myUser.clearanceLevel)
        .then((res) {
      print("successfully retrieved user levels");

      if (res.docs.isNotEmpty) {
        List<UserLevel> _userLevels = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final UserLevel userLevel = UserLevel.fromMap(data);
          _userLevels.add(userLevel);
        }

        setState(() {
          mUserLevels = _userLevels;
          _isUserLevelsLoading = false;
        });
      } else {
        print('no user levels found!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('manage | users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => UserAddEditScreen(
                    user: Dummy.getDummyUser(),
                    task: 'Add',
                    userLevels: mUserLevels,
                  )));
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'new user',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _isUserLevelsLoading ? const SizedBox() : _displayUserLevels(context),
        // _displayOptions(context),
        // const Divider(),
        const SizedBox(height: 5.0),
        _buildUsers(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _displayUserLevels(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return Container(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 14,
      child: ListView.builder(
          itemCount: mUserLevels.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mUserLevels[index].name,
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2.5,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    _selectedType = mUserLevels[index].name;
                    print(_selectedType + ' user level is selected');
                  });
                });
          }),
    );
  }

  _buildUsers(BuildContext context) {
    int sLevel = 1;
    for (UserLevel userLevel in mUserLevels) {
      if (userLevel.name == _selectedType.toLowerCase()) {
        sLevel = userLevel.level;
        break;
      }
    }

    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUsersByLevel(sLevel),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<User> _users = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final User _user = Fresh.freshUserMap(data, false);
            _users.add(_user);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayUsers(context, _users);
            }
          }
          return const Center(child: Text('pulling users...'));
        });
  }

  _displayUsers(BuildContext context, List<User> users) {
    return Expanded(
      child: ListView.builder(
          itemCount: users.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: UserItem(
                  user: users[index],
                ),
                onDoubleTap: () {
                  User sUser = users[index];
                  logger.d('double tap user selected : ' + sUser.name);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("delete user : " + sUser.name),
                        content:
                            const Text("would you like to delete the user?"),
                        actions: [
                          TextButton(
                            child: const Text("yes"),
                            onPressed: () {
                              if(sUser.imageUrl.isNotEmpty) {
                                FirestorageHelper.deleteFile(sUser.imageUrl);
                              }
                              FirestoreHelper.deleteUser(sUser);

                              print('user is deleted');

                              Navigator.of(context).pop();
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
                },
                onTap: () {
                  User sUser = users[index];
                  logger.d('user selected : ' + sUser.name);

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => UserAddEditScreen(
                            user: sUser,
                            task: 'edit',
                            userLevels: mUserLevels,
                          )));
                });
          }),
    );
  }
}
