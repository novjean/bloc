import 'package:floor/floor.dart';

@entity
class Item {
  @primaryKey
  final String id;
  final String name;
  final String type;
  final String description;
  final double price;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

  Item(this.id, this.name, this.type, this.description, this.price,
      this.serviceId, this.imageUrl, this.ownerId, this.createdAt);
}
