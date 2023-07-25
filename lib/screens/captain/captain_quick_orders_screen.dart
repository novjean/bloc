import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/quick_order.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';
import '../../widgets/captain/captain_quick_order_item.dart';
import '../../widgets/ui/app_bar_title.dart';
import '../../widgets/ui/loading_widget.dart';
import '../../widgets/ui/sized_listview_block.dart';

class CaptainQuickOrdersScreen extends StatefulWidget {
  String blocServiceId;

  CaptainQuickOrdersScreen({required this.blocServiceId});

  @override
  State<CaptainQuickOrdersScreen> createState() => _CaptainQuickOrdersScreenState();
}

class _CaptainQuickOrdersScreenState extends State<CaptainQuickOrdersScreen> {
  static const String _TAG = 'OrdersScreen';

  List<QuickOrder> mPendingOrders = [];
  List<QuickOrder> mCompletedOrders = [];

  late List<String> mOptions;
  String sOption = '';

  List<String> mSortTypes = ['drinks', 'table', 'time'];
  late String sortBy;

  @override
  void initState() {
    mOptions = ['pending', 'completed'];
    sOption = mOptions.first;

    sortBy = mSortTypes[1];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Constants.background,
        appBar: AppBar(
          title: AppBarTitle(title: 'captain orders'),
          titleSpacing: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showSortDialog(context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: 'actions',
          elevation: 5,
          splashColor: Colors.grey,
          child: const Icon(
            Icons.sort_outlined,
            color: Colors.black,
            size: 29,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _showOrderOptions(context),
        _loadOrders(context),
        const SizedBox(height: 10.0),
      ],
    );
  }

  _showSortDialog(BuildContext context) {
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
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'sort',
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
                              Text(mSortTypes[0]),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () {
                                        setState(() {
                                          sortBy = mSortTypes[0];
                                        });
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.fastfood_outlined),
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
                              Text(mSortTypes[1]),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        setState(() {
                                          sortBy = mSortTypes[1];
                                        });
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.table_bar_outlined),
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
                              Text(mSortTypes[2]),
                              SizedBox.fromSize(
                                size: const Size(50, 50),
                                child: ClipOval(
                                  child: Material(
                                    color: Constants.primary,
                                    child: InkWell(
                                      splashColor: Constants.darkPrimary,
                                      onTap: () async {
                                        setState(() {
                                          sortBy = mSortTypes[2];
                                        });
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.access_time_outlined),
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

  _showOrderOptions(BuildContext context) {
    double containerHeight = mq.height * 0.2;

    return SizedBox(
      key: UniqueKey(),
      // this height has to match with category item container height
      height: MediaQuery.of(context).size.height / 15,
      child: ListView.builder(
          itemCount: mOptions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: SizedListViewBlock(
                  title: mOptions[index],
                  height: containerHeight,
                  width: mq.width / 2,
                  color: Constants.primary,
                ),
                onTap: () {
                  setState(() {
                    sOption = mOptions[index];
                    Logx.i(_TAG, '$sOption at box office is selected');
                  });
                });
          }),
    );
  }

  _loadOrders(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getAllQuickOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          mPendingOrders = [];
          mCompletedOrders = [];

          if(snapshot.data!.docs.isNotEmpty){
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot document = snapshot.data!.docs[i];
              Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
              final QuickOrder quickOrder = Fresh.freshQuickOrderMap(map, true);

              if(quickOrder.status == 'ordered'){
                mPendingOrders.add(quickOrder);
              } else {
                mCompletedOrders.add(quickOrder);
              }

              if (i == snapshot.data!.docs.length - 1) {
                return _showOrders(context);
              }
            }
          } else {
            return const Center(
              child: Text('no orders placed yet! 😲',
                  style: TextStyle(fontSize: 20, color: Constants.darkPrimary)),
            );
          }

          Logx.i(_TAG, 'loading orders...');
          return const LoadingWidget();
        });
  }

  _showOrders(BuildContext context) {
    List<QuickOrder> quickOrders = sOption == mOptions.first? mPendingOrders : mCompletedOrders;;

    if(sortBy == mSortTypes[0]){
      //drinks
      quickOrders.sort((a, b) => a.productId.compareTo(b.productId));
    } else if(sortBy == (mSortTypes[1])){
      //table
      quickOrders.sort((a, b) => a.table.compareTo(b.table));
    } else {
      //time
      quickOrders = sOption == mOptions.first? mPendingOrders : mCompletedOrders;
    }

    return Expanded(
      child: ListView.builder(
          itemCount: quickOrders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            QuickOrder quickOrder = quickOrders[index];
            return CaptainQuickOrderItem(
              quickOrder: quickOrder,
            );
          }),
    );
  }
}