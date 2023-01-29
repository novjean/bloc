import 'package:bloc/db/entity/manager_service.dart';
import 'package:bloc/screens/manager/orders/manage_orders_screen.dart';
import 'package:bloc/screens/manager/parties/manage_parties_screen.dart';

import 'package:bloc/screens/manager/users/manage_users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/bloc_repository.dart';
import '../../db/entity/bloc_service.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/ui/listview_block.dart';
import 'bookings/bookings_screen.dart';
import 'inventory/manage_inventory_screen.dart';
import 'tables/manage_tables_screen.dart';

class ManagerServicesScreen extends StatelessWidget {
  BlocService blocService;

  ManagerServicesScreen({key, required this.blocService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('manager | services'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 2.0),
        _buildManagerServices(context),
        SizedBox(height: 10.0),
      ],
    );
  }

  _buildManagerServices(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getManagerServicesSnapshot(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<ManagerService> _managerServices = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final ManagerService ms = ManagerService.fromMap(data);
            _managerServices.add(ms);
            // BlocRepository.insertManagerService(dao, ms);

            if (i == snapshot.data!.docs.length - 1) {
              return _displayManagerServices(context, _managerServices);
            }
          }
          return Text('loading services...');
        });
  }

  _displayManagerServices(BuildContext context, List<ManagerService> _managerServices) {
    String userTitle = 'Manager';

    return Expanded(
      child: ListView.builder(
          itemCount: _managerServices.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            ManagerService _managerService = _managerServices[index];

            return GestureDetector(
                child: ListViewBlock(
                  title: _managerServices[index].name,
                ),
                onTap: () {
                  switch (_managerServices[index].name) {
                    case 'Orders':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) =>
                                ManageOrdersScreen(
                                    serviceId: blocService.id,
                                    serviceName: _managerService.name,
                                  userTitle: userTitle)));
                        logger.d('manage inventory screen selected.');
                        break;
                      }
                    case 'Inventory':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageInventoryScreen(
                                serviceId: blocService.id,
                                managerService: _managerService)));
                        logger.d('manage inventory screen selected.');
                        break;
                      }
                    case 'Tables':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageTablesScreen(
                                blocServiceId: blocService.id,
                                serviceName: _managerService.name,
                                userTitle: userTitle,)));
                        logger.d('tables management service selected.');
                        break;
                      }
                    case 'Party':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManagePartiesScreen(
                              serviceId: blocService.id,
                              managerService: _managerService)));
                        logger.d('parties management service selected.');
                        break;
                      }
                    case 'Bookings':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => BookingsScreen(
                              blocServiceId: blocService.id,
                              serviceName: _managerService.name,
                              userTitle: userTitle,)));
                        logger.d('tables management service selected.');
                        break;
                      }
                    case 'Users':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageUsersScreen()));
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