import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/user.dart' as blocUser;
import 'package:bloc/widgets/app_drawer.dart';
import 'package:bloc/widgets/map/location_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../db/entity/person.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home-screen';
  var logger = Logger();

  final BlocDao dao;
  final blocUser.User user;
  HomeScreen({key, required this.dao, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLOC'),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: const [
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //todo: need to find a solution for the one below
          // LocationInput(null),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Center(
              child: Text('Welcome to BLOC!'),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  void _insertPerson(BlocDao dao) async {
    final person = Person(1, 'Frank');
    await dao.insertPerson(person);
    final result = await dao.findAllPersons();
    logger.i('result length is ' + result.length.toString());
  }}
