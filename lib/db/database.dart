import 'dart:async';
import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/bloc_dao.dart';
import 'entity/bloc.dart';
import 'entity/cart_item.dart';
import 'entity/city.dart';
import 'entity/product.dart';
import 'entity/person.dart';
import 'entity/user.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 12, entities: [
  Bloc,
  BlocService,
  CartItem,
  Category,
  City,
  Person,
  Product,
  User
])
abstract class AppDatabase extends FloorDatabase {
  BlocDao get blocDao;
}

// flutter packages pub run build_runner build
