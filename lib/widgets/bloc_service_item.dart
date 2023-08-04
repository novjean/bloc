import 'package:flutter/material.dart';

import '../db/entity/bloc_service.dart';
import '../screens/bloc/bloc_menu_screen.dart';
import '../screens/manager/manager_services_screen.dart';
import '../screens/owner/bloc_service_add_edit_screen.dart';
import '../utils/constants.dart';

class BlocServiceItem extends StatelessWidget {
  final Key key;
  final BlocService service;
  final bool isManager;

  const BlocServiceItem(this.service, this.isManager,
      {required this.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            service.name,
            textAlign: TextAlign.center,
          ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => BlocServiceAddEditScreen(blocService: service,task: 'Edit',)),
                );
              },
              color: Constants.primary,
            )
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => isManager
                      ? ManagerServicesScreen(blocService: service)
                      : BlocMenuScreen(blocId: service.blocId)),
            );
          },
          child: Hero(
            // hero should be wired in with where we are animating to
            tag: service.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/logo.png'),
              image: service.imageUrl != "url"
                  ? NetworkImage(service.imageUrl)
                  : const NetworkImage("assets/images/logo.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
