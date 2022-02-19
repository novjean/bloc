import 'package:floor/floor.dart';

@entity
class Category {
  @primaryKey
  final String id;
  final String name;
  final String type;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final String createdAt;
  final int sequence;

  Category(this.id, this.name, this.type, this.serviceId, this.imageUrl,
      this.ownerId, this.createdAt, this.sequence);
}