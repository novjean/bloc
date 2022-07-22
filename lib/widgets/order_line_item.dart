import 'package:flutter/material.dart';

import '../db/entity/bloc_order.dart';
import '../db/entity/user.dart';

class OrderLineItem extends StatelessWidget {
  final BlocOrder order;
  final User user;

  OrderLineItem({required this.order, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
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
            // Image.asset(
            //   cat["img"],
            //   height: MediaQuery.of(context).size.height / 6,
            //   width: MediaQuery.of(context).size.height / 6,
            //   fit: BoxFit.cover,
            // ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.2, 0.7],
                  colors: [
                    Color.fromARGB(100, 0, 0, 0),
                    Color.fromARGB(100, 0, 0, 0),
                  ],
                  // stops: [0.0, 0.1],
                ),
              ),
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width,
            ),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(1),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    user.name,
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