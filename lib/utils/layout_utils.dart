import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../db/entity/quick_table.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/table_preferences.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/dummy.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../widgets/ui/button_widget.dart';
import 'constants.dart';
import 'logx.dart';

class LayoutUtils {
  static const String _TAG = 'LayoutUtils';

  BuildContext context;
  String blocServiceId;

  LayoutUtils({required this.context, required this.blocServiceId});

  void showTableSelectBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Constants.background,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (ctx) {
          return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                  top: mq.height * .03, bottom: mq.height * .05),
              children: [
                //pick profile picture label
                Text('please select your table',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Constants.lightPrimary,
                        fontWeight: FontWeight.w500)),

                //for adding some space
                SizedBox(height: mq.height * .02),
                Padding(
                  padding: EdgeInsets.only(left: mq.width * 0.1),
                  child: Text('entrance',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Constants.lightPrimary,
                          fontWeight: FontWeight.w500)),
                ),
                SizedBox(height: mq.height * .01),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 5, left: 10,right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        text: 'e1',
                        onClicked: () {
                          updateQuickTable('e1');

                          Navigator.pop(ctx);
                        },
                      ),
                      ButtonWidget(
                        text: 'e2',
                        onClicked: () {
                          updateQuickTable('e2');

                          Navigator.pop(ctx);
                        },
                      ),
                      ButtonWidget(
                        text: 'e3',
                        onClicked: () {
                          updateQuickTable('e3');

                          Navigator.pop(ctx);
                        },
                      ),
                      ButtonWidget(
                        text: '',
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: 'g1',
                        onClicked: () {
                          updateQuickTable('g1');

                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        text: 's1',
                        onClicked: () {
                          updateQuickTable('s1');

                          Navigator.pop(ctx);
                        },
                      ),
                      ButtonWidget(
                        text: 's2',
                        onClicked: () {
                          updateQuickTable('s2');

                          Navigator.pop(ctx);
                        },
                      ),
                      ButtonWidget(
                        text: 's3',
                        onClicked: () {
                          updateQuickTable('s3');

                          Navigator.pop(ctx);
                        },
                      ),
                      ButtonWidget(
                        text: '',
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: 'g2',
                        onClicked: () {
                          updateQuickTable('g2');

                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        text: '',
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: '',
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: '',
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: '',
                        onClicked: () {},
                      ),
                      ButtonWidget(
                        text: 'g3',
                        onClicked: () {
                          updateQuickTable('g3');

                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: 'b1',
                          onClicked: () {
                            updateQuickTable('b1');

                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: 'b2',
                          onClicked: () {
                            updateQuickTable('b2');

                            Navigator.pop(ctx);
                          },
                        ),
                      ),

                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: 'b3',
                          onClicked: () {
                            updateQuickTable('b3');

                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: '',
                          onClicked: () {},
                        ),
                      ),
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: 'g4',
                          onClicked: () {
                            updateQuickTable('g4');

                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5.0, bottom: 5, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: '',
                          onClicked: () {},
                        ),
                      ),
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: '',
                          onClicked: () {},
                        ),
                      ),
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: '',
                          onClicked: () {},
                        ),
                      ),
                      Flexible(
                        flex:1,
                        child: ButtonWidget(
                          text: '',
                          onClicked: () {},
                        ),
                      ),
                      Flexible(flex: 1, child: ButtonWidget(
                        text: 'g5',
                        onClicked: () {
                          Logx.i(_TAG, 'table gazebo 5 selected');
                          updateQuickTable('g5');
                          Navigator.pop(ctx);
                        },
                      ),),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: mq.width * 0.33),
                  child: Text('bar',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Constants.lightPrimary,
                          fontWeight: FontWeight.w500)),
                ),
              ]);
        });
  }

  void updateQuickTable(String tableName) async {
    Logx.d(_TAG, 'table selected $tableName');
    TablePreferences.setQuickTable(tableName);

    User user;

    try{
      user = UserPreferences.myUser;
    } catch (e) {
      await UserPreferences.init();
      user = UserPreferences.myUser;
    }

    FirestoreHelper.pullQuickTable(user.phoneNumber).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        QuickTable qt = Fresh.freshQuickTableMap(data, false);
        qt = qt.copyWith(tableName: tableName,createdAt: Timestamp.now().millisecondsSinceEpoch );
        FirestoreHelper.pushQuickTable(qt, context);
      } else {
        QuickTable quickTable = Dummy.getDummyQuickTable();
        quickTable = quickTable.copyWith(
            phone: user.phoneNumber,
            tableName: tableName);
        FirestoreHelper.pushQuickTable(quickTable, context);
      }
    });
  }

}