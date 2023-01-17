import 'package:bloc/screens/manager/users/users_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/bloc_repository.dart';
import '../../db/entity/captain_service.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/ui/listview_block.dart';
import '../manager/orders/manage_orders_screen.dart';
import '../manager/tables/tables_management_screen.dart';

class CaptainMainScreen extends StatelessWidget {
  String blocServiceId;

  CaptainMainScreen({key, required this.blocServiceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captain | Services'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.0),
        _buildCaptainServices(context),
        SizedBox(height: 10.0),
      ],
    );
  }

  _buildCaptainServices(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getCaptainServices(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
          return Text('loading captain services...');
        });
  }

  _displayCaptainServices(BuildContext context, List<CaptainService> captainServices) {
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
                            builder: (ctx) => ManageOrdersScreen(
                                  serviceId: blocServiceId,
                                  serviceName: captainService.name,
                                  userTitle: userTitle,
                                )));
                        logger.d('manage inventory screen selected.');
                        break;
                      }
                    case 'Table Management':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => TablesManagementScreen(
                                  blocServiceId: blocServiceId,
                                  serviceName: captainService.name,
                                  userTitle: userTitle,
                                )));
                        logger.d('manage inventory screen selected.');
                        break;
                      }
                    case 'Revenue':
                      {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (ctx) => TablesManagementScreen(
                        //         serviceId: blocService.id,
                        //         managerService: captainService,
                        //         dao: dao)));
                        logger.d('revenue service selected.');
                        break;
                      }
                    case 'Profile':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => UsersManagementScreen()));
                        logger.d('manage users screen selected.');
                        break;
                      }
                    default:
                  }
                });
          }),
    );
  }
}
