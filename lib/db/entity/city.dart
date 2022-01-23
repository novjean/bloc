import 'package:floor/floor.dart';

@entity
class City {
  @primaryKey
  final String id;
  final String name;
  final String ownerId;
  final String imageUrl;

  City(
    this.id,
    this.name,
    this.ownerId,
    this.imageUrl,
  );
}
