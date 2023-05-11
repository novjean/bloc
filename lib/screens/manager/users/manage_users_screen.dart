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
import '../../../utils/logx.dart';
import '../../../widgets/manager/user_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';
import '../../../widgets/ui/system_padding.dart';
import '../../../widgets/ui/toaster.dart';

class ManageUsersScreen extends StatefulWidget {
  ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const String _TAG = 'ManageUsersScreen';

  String _selectedType = 'customer';
  String sUserLevelName = 'customer';
  late UserLevel sUserLevel;
  List<UserLevel> mUserLevels = [];
  List<String> mUserLevelNames = [];

  var _isUserLevelsLoading = true;

  int sChallengeLevel = 1;

  @override
  void initState() {
    super.initState();

    sUserLevel = Dummy.getDummyUserLevel();

    // lets pull in user levels
    FirestoreHelper.pullUserLevels(UserPreferences.myUser.clearanceLevel)
        .then((res) {
      Logx.i(_TAG, 'successfully retrieved user levels');

      if (res.docs.isNotEmpty) {
        List<UserLevel> _userLevels = [];
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final UserLevel userLevel = UserLevel.fromMap(data);
          _userLevels.add(userLevel);
          mUserLevelNames.add(userLevel.name);
        }

        setState(() {
          mUserLevels = _userLevels;
          _isUserLevelsLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no user levels found!');
        setState(() {
          _isUserLevelsLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('manage | users')),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return _isUserLevelsLoading? const LoadingWidget():
    Column(
      children: [
        const SizedBox(height: 5.0),
        _displayUserLevelsDropdown(context),
        const SizedBox(height: 5.0),
        _buildUsers(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _displayUserLevelsDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('user_levels_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: TextStyle(
                    color: Theme.of(context).errorColor, fontSize: 16.0),
                hintText: 'please select user level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 0.0),
                )),
            isEmpty: sUserLevelName == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: TextStyle(color: Theme.of(context).primaryColor),
                dropdownColor: Theme.of(context).backgroundColor,
                value: sUserLevelName,
                isDense: true,
                onChanged: (String? newValue) {
                  setState(() {
                    sUserLevelName = newValue!;

                    for (UserLevel level in mUserLevels) {
                      if (level.name == sUserLevelName) {
                        sUserLevel = level;
                        break;
                      }
                    }

                    state.didChange(newValue);
                  });
                },
                items: mUserLevelNames.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  _displayUserLevels(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
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
                    Logx.i(_TAG, '$_selectedType user level is selected');
                  });
                });
          }),
    );
  }

  _buildUsers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUsersByLevel(sUserLevel.level),
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
          return const LoadingWidget();
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
                  Logx.i(_TAG, 'double tap user selected : ' + sUser.name);

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
                              Logx.i(_TAG, 'user is deleted');

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
                  Logx.i(_TAG, 'user selected : ${sUser.name}');

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
