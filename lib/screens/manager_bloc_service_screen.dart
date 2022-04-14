import 'package:bloc/db/entity/manager_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../db/bloc_repository.dart';
import '../db/dao/bloc_dao.dart';
import '../db/entity/bloc_service.dart';
import '../db/entity/cart_item.dart';
import '../db/entity/order.dart';
import '../helpers/firestore_helper.dart';
import '../utils/manager_utils.dart';
import '../widgets/manager_service_item.dart';
import 'manager/tables_management_screen.dart';
import 'orders_screen.dart';

class ManagerBlocServiceScreen extends StatelessWidget {
  BlocDao dao;
  BlocService service;

  ManagerBlocServiceScreen({key, required this.dao, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Services'),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.0),
          _buildManagerServices(context),
          // _buildOrders(context),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildManagerServices(BuildContext context) {
    final Stream<QuerySnapshot> _managerStream =
        FirestoreHelper.getManagerServicesSnapshot();

    return StreamBuilder<QuerySnapshot>(
        stream: _managerStream,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final ManagerService ms =
                ManagerUtils.getManagerService(data, document.id);
            BlocRepository.insertManagerService(dao, ms);

            if (i == snapshot.data!.docs.length - 1) {
              return displayManagerServices(context, service.id);
            }
          }
          return Text('loading services...');
        });
  }

  displayManagerServices(BuildContext context, String serviceId) {
    Stream<List<ManagerService>> _stream = dao.getManagerServices();

    return Container(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          } else {
            List<ManagerService> services =
                snapshot.data! as List<ManagerService>;

            return ListView.builder(
              primary: false,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: services.length,
              itemBuilder: (BuildContext ctx, int index) {
                ManagerService managerService = services[index];
                return GestureDetector(
                    child: ManagerServiceItem(
                      managerService: managerService,
                      serviceId: serviceId,
                    ),
                    onTap: () {
                      {
                        logger.d('manager service index selected : ' +
                            index.toString());

                        switch (index) {
                          case 0:
                            {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => OrdersScreen(
                                      serviceId: serviceId,
                                      managerService: managerService,
                                      dao: dao)));
                              break;
                            }
                          case 1:
                            {
                              logger.d('completed orders service selected.');
                              break;
                            }
                          case 2:
                            {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => TablesManagementScreen(
                                      serviceId: serviceId,
                                      managerService: managerService,
                                      dao: dao)));
                              logger.d('tables management service selected.');
                              break;
                            }
                          default:
                        }
                      }
                    });
              },
            );
          }
        },
      ),
    );
  }
}

