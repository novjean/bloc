import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/entity/party.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';

class MiniArtistItem extends StatelessWidget{
  Party artist;

  MiniArtistItem({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).pushNamed(RouteConstants.artistRouteName,
            pathParameters: {
              'name': artist.name,
              'genre': artist.genre
            });
      },
      child: Container(
          decoration: BoxDecoration(
            color: Constants.darkPrimary,
            borderRadius: BorderRadius.circular(4), // Adjust the radius as needed
          ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            '${artist.chapter} ${artist.name}',
            style: TextStyle(fontSize: 15, color: Constants.primary),
          ),
        ),
      ),
    );
  }

}