import 'package:bloc/db/bloc_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/service_table.dart';
import '../../../db/entity/user.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../widgets/manager/user_item.dart';

class UsersManagementScreen extends StatelessWidget {
  // String serviceId;
  // BlocDao dao;
  // ManagerService managerService;

  UsersManagementScreen();
      // {required this.serviceId,
      //   required this.dao,
      //   required this.managerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manager | Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //       builder: (ctx) => NewServiceTableScreen(serviceId: serviceId)),
          // );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Table',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          _buildUsers(context),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _buildUsers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getUsers(Constants.MANAGER_LEVEL),
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
            // BlocRepository.insertServiceTable(dao, serviceTable);
            _users.add(_user);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayUsers(context, _users);
            }
          }
          return Text('Pulling users...');
        });
  }

  _displayUsers(
      BuildContext context, List<User> users) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: users.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(

                child: UserItem(
                  user: users[index],
                ),
                onDoubleTap: () {
                  logger.d('double tap selected : ' + index.toString());
                  // FirestoreHelper.changeTableColor(serviceTables[index]);
                },
                onTap: () {
                  logger.d('tap selected : ' + index.toString());
                  // showOptionsDialog(context, serviceTables[index]);
                });
          }),
    );
  }

  showOptionsDialog(BuildContext context, ServiceTable _table) {
    // set up the AlertDialog for Table options
    AlertDialog alert = AlertDialog(
      title: Text("Table Options"),
      content: Text("Please select what action would you like to perform."),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed:  () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Change Color"),
          onPressed:  () {
            Navigator.of(context).pop();

            FirestoreHelper.changeTableColor(_table);
          },
        ),
        TextButton(
          child: Text("Manage Seats"),
          onPressed:  () {
            Navigator.of(context).pop();

            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //       builder: (context) => SeatsManagementScreen(
            //           serviceId: serviceId,
            //           dao: dao,
            //           serviceTable: _table)),
            // );
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
