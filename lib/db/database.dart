import 'dart:async';
import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/bloc_dao.dart';
import 'entity/bloc.dart';
import 'entity/cart_item.dart';
import 'entity/city.dart';
import 'entity/manager_service.dart';
import 'entity/product.dart';
import 'entity/seat.dart';
import 'entity/service_table.dart';
import 'entity/user.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 20, entities: [
  Bloc,
  BlocService,
  CartItem,
  Category,
  City,
  Product,
  User,
  ManagerService,
  ServiceTable,
  Seat,
])
abstract class AppDatabase extends FloorDatabase {
  BlocDao get blocDao;
}

final migration18to19 = Migration(18, 19, (database) async {
  await database.execute('ALTER TABLE Seat ADD COLUMN tableId TEXT');
});

final migration19to20 = Migration(19, 20, (database) async {
  await database.execute('ALTER TABLE Product ADD COLUMN priceCommunity DOUBLE');
});

// flutter packages pub run build_runner build
