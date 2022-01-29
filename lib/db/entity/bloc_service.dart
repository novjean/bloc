import 'package:floor/floor.dart';

@entity
class BlocService {
  @primaryKey
  final String id;
  final String name;
  final String blocId;
  final String type;
  final double primaryNumber;
  final double secondaryNumber;
  final String email;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

  BlocService(
      this.id,
      this.name,
      this.blocId,
      this.type,
      this.primaryNumber,
      this.secondaryNumber,
      this.email,
      this.imageUrl,
      this.ownerId,
      this.createdAt);
}