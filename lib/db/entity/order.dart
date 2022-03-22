import 'package:floor/floor.dart';

@entity
class Order {
  @primaryKey
  final String id;
  final String orderNumber;
  final String blocId;
  final String blocName;
  final String userId;
  final int cartNumber;
  final String createdAt;

  Order(this.id, this.orderNumber, this.blocId, this.blocName, this.userId,
      this.cartNumber, this.createdAt);
}