import 'package:flutter/material.dart';

class SizedListViewBlock extends StatelessWidget {
  final String title;
  final double height;
  final double width;

  SizedListViewBlock(
      {required this.title, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    double height = this.height;
    double width = this.width;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: <Widget>[
            // FadeInImage(
            //   placeholder: AssetImage('assets/images/product-placeholder.png'),
            //   height: height,
            //   width: width,
            //   image: cat.imageUrl != "url"
            //       ? NetworkImage(cat.imageUrl)
            //       : NetworkImage(
            //       "assets/images/product-placeholder.png"),
            //   fit: BoxFit.cover,
            // ),

            Container(
              height: height,
              width: width,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.2, 0.7],
                  colors: [
                    Color.fromARGB(0, 0, 0, 0),
                    Color.fromARGB(0, 0, 0, 0),
                  ],
                  // stops: [0.0, 0.1],
                ),
              ),
            ),
            Center(
              child: Container(
                height: height,
                width: width,
                padding: const EdgeInsets.all(5),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
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
