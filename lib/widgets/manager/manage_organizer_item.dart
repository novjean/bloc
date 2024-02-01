import 'package:bloc/db/entity/organizer.dart';
import 'package:bloc/widgets/ui/dark_button_widget.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../screens/manager/organizers/manage_organizer_screen.dart';

class ManageOrganizerItem extends StatelessWidget{
  static const String _TAG = 'ManageOrganizerItem';

  Organizer organizer;

  ManageOrganizerItem({super.key, required this.organizer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: organizer.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: organizer.imageUrl.isNotEmpty?
                  FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(organizer.imageUrl),
                    fit: BoxFit.cover,) : const SizedBox(),
                  title: Text('${organizer.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${organizer.followersCount} followers'),
                      Text('${organizer.phoneNumber}')
                    ],
                  ),
                  trailing: DarkButtonWidget(text: '👁️', onClicked: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => ManageOrganizerScreen(
                        organizer: organizer,
                      )),
                    );
                  },)
                )),
          ),
        ),
      ),
    );
  }

}