import 'package:floor/floor.dart';

@entity
class CartItem {
  @primaryKey
  final String id;
  final String serviceId;
  final int tableNumber;
  final int cartNumber;
  final String userId;
  final String productId;
  final String productName;
  final double productPrice;
  int quantity;
  bool isCompleted;
  final int createdAt;

//<editor-fold desc="Data Methods">

  CartItem({
    required this.id,
    required this.serviceId,
    required this.tableNumber,
    required this.cartNumber,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.isCompleted,
    required this.createdAt,
  });

// Ca@override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is CartItem &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              serviceId == other.serviceId &&
              tableNumber == other.tableNumber &&
              cartNumber == other.cartNumber &&
              userId == other.userId &&
              productId == other.productId &&
              productName == other.productName &&
              productPrice == other.productPrice &&
              quantity == other.quantity &&
              isCompleted == other.isCompleted &&
              createdAt == other.createdAt
          );


  @override
  int get hashCode =>
      id.hashCode ^
      serviceId.hashCode ^
      tableNumber.hashCode ^
      cartNumber.hashCode ^
      userId.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      productPrice.hashCode ^
      quantity.hashCode ^
      isCompleted.hashCode ^
      createdAt.hashCode;


  @override
  String toString() {
    return 'CartItem{' +
        ' id: $id,' +
        ' serviceId: $serviceId,' +
        ' tableNumber: $tableNumber,' +
        ' cartNumber: $cartNumber,' +
        ' userId: $userId,' +
        ' productId: $productId,' +
        ' productName: $productName,' +
        ' productPrice: $productPrice,' +
        ' quantity: $quantity,' +
        ' isCompleted: $isCompleted,' +
        ' createdAt: $createdAt,' +
        '}';
  }


  CartItem copyWith({
    String? id,
    String? serviceId,
    int? tableNumber,
    int? cartNumber,
    String? userId,
    String? productId,
    String? productName,
    double? productPrice,
    int? quantity,
    bool? isCompleted,
    int? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      tableNumber: tableNumber ?? this.tableNumber,
      cartNumber: cartNumber ?? this.cartNumber,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'cartId': this.id,
      'serviceId': this.serviceId,
      'tableNumber': this.tableNumber,
      'cartNumber': this.cartNumber,
      'userId': this.userId,
      'productId': this.productId,
      'productName': this.productName,
      'productPrice': this.productPrice,
      'quantity': this.quantity,
      'isCompleted': this.isCompleted,
      'createdAt': this.createdAt,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['cartId'] as String,
      serviceId: map['serviceId'] as String,
      tableNumber: map['tableNumber'] as int,
      cartNumber: map['cartNumber'] as int,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      productPrice: map['productPrice'] as double,
      quantity: map['quantity'] as int,
      isCompleted: map['isCompleted'] as bool,
      createdAt: map['createdAt'] as int,
    );
  }

  //</editor-fold>

}
