import 'package:floor/floor.dart';

@entity
class CartItem {
  @primaryKey
  final String cartId;
  final String serviceId;
  String billId;
  final int tableNumber;
  final int cartNumber;
  final String userId;
  final String productId;
  final String productName;
  final double productPrice;
  final bool isCommunity;
  int quantity;
  bool isCompleted;
  bool isBilled;
  final int createdAt;

//<editor-fold desc="Data Methods">

  CartItem({
    required this.cartId,
    required this.serviceId,
    required this.billId,
    required this.tableNumber,
    required this.cartNumber,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.isCommunity,
    required this.quantity,
    required this.isCompleted,
    required this.isBilled,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItem &&
          runtimeType == other.runtimeType &&
          cartId == other.cartId &&
          serviceId == other.serviceId &&
          billId == other.billId &&
          tableNumber == other.tableNumber &&
          cartNumber == other.cartNumber &&
          userId == other.userId &&
          productId == other.productId &&
          productName == other.productName &&
          productPrice == other.productPrice &&
          isCommunity == other.isCommunity &&
          quantity == other.quantity &&
          isCompleted == other.isCompleted &&
          isBilled == other.isBilled &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      cartId.hashCode ^
      serviceId.hashCode ^
      billId.hashCode ^
      tableNumber.hashCode ^
      cartNumber.hashCode ^
      userId.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      productPrice.hashCode ^
      isCommunity.hashCode ^
      quantity.hashCode ^
      isCompleted.hashCode ^
      isBilled.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'CartItem{' +
        ' cartId: $cartId,' +
        ' serviceId: $serviceId,' +
        ' billId: $billId,' +
        ' tableNumber: $tableNumber,' +
        ' cartNumber: $cartNumber,' +
        ' userId: $userId,' +
        ' productId: $productId,' +
        ' productName: $productName,' +
        ' productPrice: $productPrice,' +
        ' isCommunity: $isCommunity,' +
        ' quantity: $quantity,' +
        ' isCompleted: $isCompleted,' +
        ' isBilled: $isBilled,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  CartItem copyWith({
    String? cartId,
    String? serviceId,
    String? billId,
    int? tableNumber,
    int? cartNumber,
    String? userId,
    String? productId,
    String? productName,
    double? productPrice,
    bool? isCommunity,
    int? quantity,
    bool? isCompleted,
    bool? isBilled,
    int? createdAt,
  }) {
    return CartItem(
      cartId: cartId ?? this.cartId,
      serviceId: serviceId ?? this.serviceId,
      billId: billId ?? this.billId,
      tableNumber: tableNumber ?? this.tableNumber,
      cartNumber: cartNumber ?? this.cartNumber,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      isCommunity: isCommunity ?? this.isCommunity,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      isBilled: isBilled ?? this.isBilled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartId': this.cartId,
      'serviceId': this.serviceId,
      'billId': this.billId,
      'tableNumber': this.tableNumber,
      'cartNumber': this.cartNumber,
      'userId': this.userId,
      'productId': this.productId,
      'productName': this.productName,
      'productPrice': this.productPrice,
      'isCommunity': this.isCommunity,
      'quantity': this.quantity,
      'isCompleted': this.isCompleted,
      'isBilled': this.isBilled,
      'createdAt': this.createdAt,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      cartId: map['cartId'] as String,
      serviceId: map['serviceId'] as String,
      billId: map['billId'] as String,
      tableNumber: map['tableNumber'] as int,
      cartNumber: map['cartNumber'] as int,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      productPrice: map['productPrice'] as double,
      isCommunity: map['isCommunity'] as bool,
      quantity: map['quantity'] as int,
      isCompleted: map['isCompleted'] as bool,
      isBilled: map['isBilled'] as bool,
      createdAt: map['createdAt'] as int,
    );
  }

//</editor-fold>
}
