import 'package:bloc/db/entity/category.dart';
import 'package:bloc/db/entity/person.dart';
import 'package:floor/floor.dart';

import '../entity/bloc.dart';
import '../entity/bloc_service.dart';
import '../entity/city.dart';
import '../entity/user.dart';

@dao
abstract class BlocDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id = :id')
  Stream<Person?> findPersonById(int id);

  @insert
  Future<void> insertPerson(Person person);

  @insert
  Future<void> insertUser(User user);

  @insert
  Future<void> insertCity(City city);

  @insert
  Future<void> insertBloc(Bloc bloc);

  @insert
  Future<void> insertBlocService(BlocService service);

  @insert
  Future<void> insertCategory(Category cat);

  @Query('SELECT * FROM Category ORDER BY sequence ASC')
  Stream<List<Category>> getCategoriesStream();

}