import 'package:bloc/screens/captain/captain_orders_screen.dart';
import 'package:bloc/screens/captain/captain_tables_screen.dart';
import 'package:bloc/screens/manager/users/manage_users_screen.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/captain_service.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/ui/listview_block.dart';

class CaptainMainScreen extends StatelessWidget {
  static const String _TAG = 'CaptainMainScreen';

  String blocServiceId;

  CaptainMainScreen({key, required this.blocServiceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('captain | services'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _buildCaptainServices(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildCaptainServices(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCaptainServices(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget();
          }

          List<CaptainService> _captainServices = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final CaptainService cs = CaptainService.fromMap(data);
            _captainServices.add(cs);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayCaptainServices(context, _captainServices);
            }
          }
          print('loading captain services...');
          return LoadingWidget();
        });
  }

  _displayCaptainServices(
      BuildContext context, List<CaptainService> captainServices) {
    String userTitle = 'Captain';
    return Expanded(
      child: ListView.builder(
          itemCount: captainServices.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            CaptainService captainService = captainServices[index];

            return GestureDetector(
                child: ListViewBlock(
                  title: captainServices[index].name,
                ),
                onTap: () {
                  switch (captainServices[index].name) {
                    case 'Orders':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => CaptainOrdersScreen(
                                  serviceId: blocServiceId,
                                )));
                        break;
                      }
                    case 'Table Management':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => CaptainTablesScreen(
                                  blocServiceId: blocServiceId,
                                  serviceName: captainService.name,
                                  userTitle: userTitle,
                                )));
                        break;
                      }
                    case 'Revenue':
                      {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (ctx) => TablesManagementScreen(
                        //         serviceId: blocService.id,
                        //         managerService: captainService,
                        //         dao: dao)));
                        break;
                      }
                    case 'Profile':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageUsersScreen()));
                        break;
                      }
                    default:
                  }
                });
          }),
    );
  }
}
