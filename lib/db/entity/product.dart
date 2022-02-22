import 'package:floor/floor.dart';

@entity
class Product {
  @primaryKey
  final String id;
  final String name;
  final String type;
  final String description;
  final int price;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

  Product(this.id, this.name, this.type, this.description, this.price,
      this.serviceId, this.imageUrl, this.ownerId, this.createdAt);
}
