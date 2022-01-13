
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

@entity
class Person {
  @primaryKey
  final int id;
  @required final String name;
  Person({@required this.id, @required this.name});
}