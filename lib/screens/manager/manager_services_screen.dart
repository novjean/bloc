import 'package:bloc/db/entity/manager_service.dart';
import 'package:bloc/screens/manager/ads/manage_ads_screen.dart';
import 'package:bloc/screens/manager/orders/manage_orders_screen.dart';
import 'package:bloc/screens/manager/parties/manage_parties_screen.dart';
import 'package:bloc/screens/manager/photos/manage_party_photos_screen.dart';
import 'package:bloc/screens/manager/promoters/manage_promoters_screen.dart';
import 'package:bloc/screens/manager/reservations/manage_reservations_screen.dart';

import 'package:bloc/screens/manager/users/manage_users_screen.dart';
import 'package:bloc/screens/parties/manage_guest_list_screen.dart';
import 'package:bloc/widgets/manager/manager_service_item.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/bloc_service.dart';
import '../../helpers/firestore_helper.dart';
import 'ad_campaigns/manage_ad_campaigns_screen.dart';
import 'celebrations/manage_celebrations_screen.dart';
import 'challenges/manage_challenges_screen.dart';
import 'configs/manage_configs_screen.dart';
import 'guest_wifi_edit_screen.dart';
import 'inventory/manage_inventory_screen.dart';
import 'lounges/manage_lounges_screen.dart';
import 'tables/manage_tables_screen.dart';

class ManagerServicesScreen extends StatelessWidget {
  static const String _TAG = 'ManagerServicesScreen';

  BlocService blocService;

  ManagerServicesScreen({key, required this.blocService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title: 'manager services',),
      ),
      // drawer: AppDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        _buildManagerServices(context),
        const SizedBox(height: 5.0),
      ],
    );
  }

  _buildManagerServices(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getManagerServicesSnapshot(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const LoadingWidget();
            case ConnectionState.active:
            case ConnectionState.done:
            {
              List<ManagerService> _managerServices = [];
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot document = snapshot.data!.docs[i];
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
                final ManagerService ms = ManagerService.fromMap(data);
                _managerServices.add(ms);
                }
              return _displayManagerServices(context, _managerServices);
            }
          }
        });
  }

  _displayManagerServices(
      BuildContext context, List<ManagerService> managerServices) {
    String userTitle = 'Manager';

    return Expanded(
      child: ListView.builder(
          itemCount: managerServices.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            ManagerService managerService = managerServices[index];

            return GestureDetector(
                child: ManagerServiceItem(
                  managerService: managerService,
                ),
                onTap: () {
                  switch (managerService.name) {
                    case 'ads':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) =>
                                ManageAdsScreen(serviceId: blocService.id)));
                        break;
                      }
                    case 'ad campaigns':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) =>
                                ManageAdCampaignsScreen(serviceId: blocService.id)));
                        break;
                      }
                    case 'challenges':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) =>
                                ManageChallengesScreen()));
                        break;
                      }
                    case 'celebrations':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageCelebrationsScreen(
                              blocServiceId: blocService.id,
                              serviceName: managerService.name,
                              userTitle: userTitle,
                            )));
                        break;
                      }
                    case 'configs':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageConfigsScreen(
                              blocServiceId: blocService.id,
                            )));
                        break;
                      }
                    case 'guest list':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageGuestListScreen()));
                        break;
                      }
                    case 'guest wifi':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => GuestWifiEditScreen(
                                  blocServiceId: blocService.id,
                                  task: 'edit',
                                )));
                        break;
                      }
                    case 'inventory':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageInventoryScreen(
                                serviceId: blocService.id,
                                managerService: managerService)));
                        break;
                      }
                    case 'lounges':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageLoungesScreen()));
                        break;
                      }
                    case 'orders':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageOrdersScreen(
                                serviceId: blocService.id,
                                serviceName: managerService.name,
                                userTitle: userTitle)));
                        break;
                      }
                    case 'parties':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManagePartiesScreen(
                                serviceId: blocService.id,
                                managerService: managerService)));
                        break;
                      }
                    case 'photos':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManagePartyPhotosScreen(
                                blocServiceId: blocService.id,)));
                        break;
                      }
                    case 'promoters':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManagePromotersScreen()));
                        break;
                      }
                    case 'reservations':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageReservationsScreen(
                              blocServiceId: blocService.id,
                              serviceName: managerService.name,
                              userTitle: userTitle,
                            )));
                        break;
                      }
                    case 'tables':
                      {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageTablesScreen(
                                  blocServiceId: blocService.id,
                                  serviceName: managerService.name,
                                  userTitle: userTitle,
                                )));
                        break;
                      }
                    case 'users':
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
