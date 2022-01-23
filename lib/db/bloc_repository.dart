
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/user.dart';
import 'package:logger/logger.dart';

import 'entity/city.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class BlocRepository {
  static void insertUser(BlocDao dao, User user) async {
    logger.i("insertUser()");
    await dao.insertUser(user);
  }

  static void insertCity(BlocDao dao, City city) async {
    logger.i("insertCity()");
    await dao.insertCity(city);
  }



}