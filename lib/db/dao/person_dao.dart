import 'package:bloc/db/entity/person.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE id IS NOT NULL and id = :id')
  Stream<Person> findPersonById({@required int id});

  @insert
  Future<void> insertPerson(Person person);
}