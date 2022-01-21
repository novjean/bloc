import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/bloc_dao.dart';
import 'entity/person.dart';
import 'entity/user.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 2, entities: [Person, User])
abstract class AppDatabase extends FloorDatabase {
  BlocDao get blocDao;
}