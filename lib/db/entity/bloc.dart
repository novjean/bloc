import 'package:floor/floor.dart';

@entity
class Bloc {
  @primaryKey
  final String id;
  final String cityName;
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

  Bloc(this.id, this.cityName, this.addressLine1, this.addressLine2,
      this.pinCode, this.imageUrl, this.ownerId, this.createdAt);

}