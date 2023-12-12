import 'package:flutter/material.dart';

import '../../db/shared_preferences/user_preferences.dart';
import '../../utils/constants.dart';

class SliderView extends StatelessWidget {
  final Function(String)? onItemClick;

  const SliderView({Key? key, this.onItemClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey,
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
              Image.network(UserPreferences.myUser.imageUrl).image,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            UserPreferences.myUser.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ...getMenuList()
              .map((menu) => _SliderMenuItem(
              title: menu.title,
              iconData: menu.iconData,
              onTap: onItemClick))
              .toList(),
        ],
      ),
    );
  }
}

List<Menu> getMenuList() {
  List<Menu> menuItems = [];

  final user = UserPreferences.getUser();

  menuItems.add(Menu(Icons.home, 'home'));
  if (UserPreferences.isUserLoggedIn()) {
    menuItems.add(Menu(Icons.keyboard_command_key_sharp, 'box office'));
    menuItems.add(Menu(Icons.bookmark_added_sharp, 'reservation'));

    if (user.clearanceLevel == Constants.CAPTAIN_LEVEL ||
        user.clearanceLevel >= Constants.MANAGER_LEVEL) {
      menuItems.add(Menu(Icons.adjust, 'captain'));
    }

    if (user.clearanceLevel == Constants.PROMOTER_LEVEL ||
        user.clearanceLevel >= Constants.MANAGER_LEVEL) {
      menuItems.add(Menu(Icons.adjust, 'promoter'));
    }

    if (user.clearanceLevel >= Constants.MANAGER_LEVEL) {
      menuItems.add(Menu(Icons.account_circle_outlined, 'manager'));
    }
    if (user.clearanceLevel >= Constants.OWNER_LEVEL) {
      menuItems.add(Menu(Icons.play_circle_outlined, 'owner'));
    }
    menuItems.add(Menu(Icons.settings, 'account'));
    menuItems.add(Menu(Icons.exit_to_app, 'logout'));
  } else {
    menuItems.add(Menu(Icons.exit_to_app, 'login'));
  }

  return menuItems;
}

class _SliderMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function(String)? onTap;

  const _SliderMenuItem(
      {Key? key,
        required this.title,
        required this.iconData,
        required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title,
            style: const TextStyle(
                color: Colors.black, fontFamily: 'BalsamiqSans_Regular')),
        leading: Icon(iconData, color: Colors.black),
        onTap: () => onTap?.call(title));
  }
}

class Menu {
  final IconData iconData;
  final String title;

  Menu(this.iconData, this.title);
}
