import 'package:floor/floor.dart';

@entity
class ManagerService {
  @primaryKey
  final String id;
  final String name;
  final int sequence;

  ManagerService(this.id, this.name, this.sequence);
}