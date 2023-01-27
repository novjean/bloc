import 'package:bloc/db/bloc_repository.dart';
import 'package:bloc/helpers/dummy.dart';
import 'package:bloc/helpers/firestorage_helper.dart';
import 'package:bloc/screens/manager/users/user_add_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/user.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/manager/user_item.dart';
import '../../../widgets/ui/sized_listview_block.dart';

class ManageUsersScreen extends StatefulWidget {
  ManageUsersScreen();

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _selectedType = 'captain';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('manager | users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) =>
                  UserAddEditScreen(user: Dummy.getDummyUser(), task: 'Add')));
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
        const SizedBox(height: 2.0),
        _displayOptions(context),
        const Divider(),
        SizedBox(height: 2.0),
        _buildUsers(context),
        SizedBox(height: 2.0),
      ],
    );
  }

  _displayOptions(BuildContext context) {
    List<String> _options = ['captain', 'customers'];
    double containerHeight = MediaQuery.of(context).size.height / 20;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: containerHeight,
      child: ListView.builder(
          itemCount: _options.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: _options[index],
                  height: containerHeight,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                onTap: () {
                  setState(() {
                    _selectedType = _options[index];
                    print(_selectedType + ' users display option is selected.');
                  });
                });
          }),
    );
  }

  _buildUsers(BuildContext context) {
    int lowLevel = 0;
    int highLevel = 9;

    if (_selectedType == 'captain') {
      lowLevel = Constants.CAPTAIN_LEVEL;
      highLevel = Constants.MANAGER_LEVEL - 1;
    } else {
      lowLevel = Constants.USER_LEVEL;
      highLevel = Constants.CAPTAIN_LEVEL - 1;
    }

    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUsersInRange(lowLevel, highLevel),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<User> _users = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final User _user = User.fromMap(data);
            _users.add(_user);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayUsers(context, _users);
            }
          }
          return Text('pulling users...');
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
                        content: Text("would you like to delete the user?"),
                        actions: [
                          TextButton(
                            child: Text("yes"),
                            onPressed: () {
                              FirestorageHelper.deleteFile(sUser.imageUrl);
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
                      builder: (ctx) =>
                          UserAddEditScreen(user: sUser, task: 'edit')));
                });
          }),
    );
  }

// showOptionsDialog(BuildContext context, ServiceTable _table) {
//   // set up the AlertDialog for Table options
//   AlertDialog alert = AlertDialog(
//     title: Text("Table Options"),
//     content: Text("Please select what action would you like to perform."),
//     actions: [
//       TextButton(
//         child: Text("Cancel"),
//         onPressed:  () {
//           Navigator.of(context).pop();
//         },
//       ),
//       TextButton(
//         child: Text("Change Color"),
//         onPressed:  () {
//           Navigator.of(context).pop();
//
//           FirestoreHelper.changeTableColor(_table);
//         },
//       ),
//       TextButton(
//         child: Text("Manage Seats"),
//         onPressed:  () {
//           Navigator.of(context).pop();
//
//           // Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //       builder: (context) => SeatsManagementScreen(
//           //           serviceId: serviceId,
//           //           dao: dao,
//           //           serviceTable: _table)),
//           // );
//         },
//       ),
//     ],
//   );
//
//   // show the dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }
}
