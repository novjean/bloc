import 'package:bloc/db/entity/notification_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../widgets/manager/manage_notification_test_item.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'notification_test_add_edit_screen.dart';

class ManageNotificationTestsScreen extends StatelessWidget {
  static const String _TAG = 'ManageNotificationTestsScreen';

  const ManageNotificationTestsScreen({Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage notification tests'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => NotificationTestAddEditScreen(
                  test: Dummy.getDummyNotificationTest(),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add notification test',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildNotificationTests(context),
    );
  }

  _buildNotificationTests(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getNotificationTests(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:{
            List<NotificationTest> tests = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final NotificationTest test = Fresh.freshNotificationTestMap(map, false);
              tests.add(test);
            }
            return _showTests(context, tests);
          }
          }
        });
  }

  _showTests(BuildContext context, List<NotificationTest> tests) {
    return SizedBox(
      height: mq.height,
      child: ListView.builder(
          itemCount: tests.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ManageNotificationTestItem(
                  notificationTest: tests[index],
                ),
                onTap: () {
                  NotificationTest sTest = tests[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => NotificationTestAddEditScreen(
                          test: sTest,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
