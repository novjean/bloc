import 'package:bloc/screens/manager/tables/seats_management.dart';
import 'package:flutter/material.dart';

import '../db/entity/service_table.dart';

class ServiceTableItem extends StatelessWidget {
  final ServiceTable serviceTable;

  ServiceTableItem({required this.serviceTable});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 10;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: <Widget>[
            // FadeInImage(
            //   placeholder: AssetImage('assets/images/product-placeholder.png'),
            //   height: MediaQuery.of(context).size.height / 6,
            //   width: MediaQuery.of(context).size.height / 6,
            //   image: cat.imageUrl != "url"
            //       ? NetworkImage(cat.imageUrl)
            //       : NetworkImage(
            //       "assets/images/product-placeholder.png"),
            //   fit: BoxFit.cover,
            // ),
            // chick

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.2, 0.7],
                  colors: [
                    Colors.grey,
                    serviceTable.colorStatus==SeatsManagementScreen.TABLE_GREEN?Colors.greenAccent:Colors.redAccent,
                  ],
                  // stops: [0.0, 0.1],
                ),
              ),
              height: height,
              width: width,
            ),
            Center(
              child: Container(
                height: height,
                width: width,
                padding: const EdgeInsets.all(1),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    'Table number: ' +
                        serviceTable.tableNumber.toString() +
                        ' . Seats: ' +
                        serviceTable.capacity.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
