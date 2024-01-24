import 'package:flutter/material.dart';

class SizedListViewBlock extends StatelessWidget {
  final String title;
  final double height;
  final double width;
  final Color? color;

  SizedListViewBlock(
      {required this.title, required this.height, required this.width, required this.color});

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
            Container(
              height: height,
              width: width,
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
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
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
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
