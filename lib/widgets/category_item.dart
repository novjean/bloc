import 'package:bloc/db/entity/category.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final Category category;

  CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 12;
    double width = MediaQuery.of(context).size.width / 2;

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Stack(
          children: <Widget>[
            FadeInImage(
              placeholder: AssetImage('assets/images/logo.png'),
              height: height,
              width: width,
              image: category.imageUrl != "url"
                  ? NetworkImage(category.imageUrl)
                  : NetworkImage(
                  "assets/images/logo.png"),
              fit: BoxFit.cover,
            ),
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
                  // stops: [0.2, 0.7],
                  colors: [
                    Color.fromARGB(100, 0, 0, 0),
                    Color.fromARGB(100, 0, 0, 0),
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
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    category.name.toLowerCase(),
                    style: const TextStyle(
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