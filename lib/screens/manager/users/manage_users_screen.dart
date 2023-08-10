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
import '../../../utils/constants.dart';
import '../../../utils/file_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/manager/user_item.dart';
import '../../../widgets/ui/app_bar_title.dart';

class ManageUsersScreen extends StatefulWidget {
  ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static const String _TAG = 'ManageUsersScreen';

  List<User> mUsers = [];

  String sUserLevelName = 'customer';
  late UserLevel sUserLevel;
  List<UserLevel> mUserLevels = [];
  List<String> mUserLevelNames = [];

  var _isUserLevelsLoading = true;

  String sGender = 'all';
  List<String> mGenders = [
    'all',
    'male',
    'female',
    'transgender',
    'non-binary/non-conforming',
    'prefer not to respond'
  ];

  String sMode = 'all';
  List<String> mModes = [
    'all',
    'app',
    'web',
  ];

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
      appBar: AppBar(
        title: AppBarTitle(title: 'manage users'),
        titleSpacing: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionsDialog(context);
        },
        backgroundColor: Constants.primary,
        tooltip: 'actions',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.science,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  showFilterDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 300,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'filter',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('levels:\n'),
                        _displayUserLevelsDropdown(context),
                        const Text('\ngender:\n'),
                        _displayGenderDropdown(context),
                        const Text('\nmode:\n'),
                        _displayModesDropdown(context)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text("confirm"),
              onPressed: () {
                setState(() {});
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _buildBody(BuildContext context) {
    return _isUserLevelsLoading ? const LoadingWidget() : _buildUsers(context);
  }

  _displayModesDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('modes_dropdown'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: const TextStyle(
                    color: Constants.errorColor, fontSize: 16.0),
                hintText: 'please select user mode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(color: Constants.primary, width: 0.0),
                )),
            isEmpty: sMode == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Constants.lightPrimary),
                dropdownColor: Constants.background,
                value: sMode,
                isDense: true,
                onChanged: (String? newValue) {
                  sMode = newValue!;
                  state.didChange(newValue);
                },
                items: mModes.map((String value) {
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

  _displayGenderDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('gender_dropdown'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: const TextStyle(
                    color: Constants.errorColor, fontSize: 16.0),
                hintText: 'please select gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(color: Constants.primary, width: 0.0),
                )),
            isEmpty: sGender == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Constants.lightPrimary),
                dropdownColor: Constants.background,
                value: sGender,
                isDense: true,
                onChanged: (String? newValue) {
                  sGender = newValue!;
                  state.didChange(newValue);
                },
                items: mGenders.map((String value) {
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

  _displayUserLevelsDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            key: const ValueKey('user_levels_key'),
            decoration: InputDecoration(
                fillColor: Colors.white,
                errorStyle: const TextStyle(
                    color: Constants.errorColor, fontSize: 16.0),
                hintText: 'please select user level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Constants.primary),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primary, width: 0.0),
                )),
            isEmpty: sUserLevelName == '',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Constants.primary),
                dropdownColor: Constants.background,
                value: sUserLevelName,
                isDense: true,
                onChanged: (String? newValue) {
                  sUserLevelName = newValue!;

                  for (UserLevel level in mUserLevels) {
                    if (level.name == sUserLevelName) {
                      sUserLevel = level;
                      break;
                    }
                  }
                  state.didChange(newValue);
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

  _buildUsers(BuildContext context) {
    Stream<QuerySnapshot<Object?>> stream;
    int iosCount = 0;
    int androidCount = 0;
    bool shouldTypeCount = false;

    if (sGender == 'all' && sMode == 'all') {
      stream = FirestoreHelper.getUsersByLevel(sUserLevel.level);
    } else if (sGender == 'all' && sMode != 'all') {
      stream = FirestoreHelper.getUsersByLevelAndMode(
          sUserLevel.level, sMode == 'app' ? true : false);
      shouldTypeCount = true;
    } else if (sGender != 'all' && sMode == 'all') {
      stream =
          FirestoreHelper.getUsersByLevelAndGender(sUserLevel.level, sGender);
    } else {
      stream = FirestoreHelper.getUsersByLevelAndGenderAndMode(
          sUserLevel.level, sGender, sMode == 'app' ? true : false);
    }

    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                mUsers = [];

                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot document = snapshot.data!.docs[i];
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  final User _user = Fresh.freshUserMap(data, false);
                  mUsers.add(_user);

                  if (shouldTypeCount) {
                    if (_user.isIos) {
                      iosCount++;
                    } else {
                      androidCount++;
                    }
                  }

                  // if (i == snapshot.data!.docs.length - 1) {
                  // }
                }
                if(shouldTypeCount){
                  Logx.ilt(_TAG, 'android : $androidCount | ios: $iosCount');
                }
                return _displayBody(context);
              }
          }

          return const LoadingWidget();
        });
  }

  _displayBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('level: ${sUserLevelName}'),
              ),
              Expanded(
                child: Text('gender: ${sGender}'),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('count: ${mUsers.length}')),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: mUsers.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (ctx, index) {
                return GestureDetector(
                    child: UserItem(
                      user: mUsers[index],
                    ),
                    onDoubleTap: () {
                      User sUser = mUsers[index];
                      Logx.i(_TAG, 'double tap user selected : ${sUser.name}');

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("delete user : ${sUser.name}"),
                            content: const Text(
                                "would you like to delete the user?"),
                            actions: [
                              TextButton(
                                child: const Text("yes"),
                                onPressed: () {
                                  if (sUser.imageUrl.isNotEmpty) {
                                    FirestorageHelper.deleteFile(
                                        sUser.imageUrl);
                                  }
                                  FirestoreHelper.deleteUser(sUser.id);
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
                      User sUser = mUsers[index];
                      Logx.i(_TAG, 'user selected : ${sUser.name}');

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => UserAddEditScreen(
                                user: sUser,
                                task: 'edit',
                                userLevels: mUserLevels,
                              )));
                    });
              }),
        ),
      ],
    );
  }

  _showActionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'actions',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('filter'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        showFilterDialog(context);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.filter_list),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('share users'),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        Navigator.of(ctx).pop();

                                        String listText = '';
                                        for (User user in mUsers) {
                                          listText +=
                                              '${user.name} ${user.surname},'
                                              '+${user.phoneNumber}\n';
                                        }

                                        String rand =
                                            StringUtils.getRandomString(5);
                                        String fileName =
                                            '$sUserLevelName-$sGender-$sMode-$rand.csv';
                                        FileUtils.shareCsvFile(
                                            fileName, listText, sUserLevelName);
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.share_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
