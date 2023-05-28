import 'package:flutter/material.dart';

import '../db/entity/bloc_service.dart';
import '../screens/bloc/bloc_menu_screen.dart';
import '../screens/manager/manager_services_screen.dart';
import '../screens/owner/bloc_service_add_edit_screen.dart';

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
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => isManager
                      ? ManagerServicesScreen(blocService: service)
                      : BlocMenuScreen(blocService: service)),
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
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            service.name,
            textAlign: TextAlign.center,
          ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => BlocServiceAddEditScreen(blocService: service,task: 'Edit',)),
                );
              },
              color: Theme.of(context).primaryColor,
            )
        ),
      ),
    );
  }
}
