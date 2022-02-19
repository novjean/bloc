
import 'package:bloc/db/dao/bloc_dao.dart';
import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/user.dart';
import 'package:logger/logger.dart';

import 'entity/bloc.dart';
import 'entity/bloc_service.dart';
import 'entity/city.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class BlocRepository {
  static void insertUser(BlocDao dao, User user) async {
    logger.i("insertUser(): " + user.username);
    await dao.insertUser(user);
  }

  static void insertCity(BlocDao dao, City city) async {
    logger.i("insertCity(): " + city.name);
    await dao.insertCity(city);
  }

  static void insertBloc(BlocDao dao, Bloc bloc) async {
    logger.i("insertBloc(): " + bloc.name);
    await dao.insertBloc(bloc);
  }

  static void insertBlocService(BlocDao dao, BlocService service) async {
    logger.i("insertBlocService(): " + service.name);
    await dao.insertBlocService(service);
  }

  static void insertCategory(BlocDao dao, Category cat) async {
    logger.i("insertCategory(): " + cat.name);
    await dao.insertCategory(cat);
  }

  static void getCategories(BlocDao dao) async {
    await dao.getCategories();
  }
}