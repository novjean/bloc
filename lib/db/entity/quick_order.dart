class QuickOrder{
  final String id;
  final String custId;
  final int custPhone;

  final String productId;
  final int quantity;

  final String table;
  final int createdAt;

  final String status;

//<editor-fold desc="Data Methods">
  const QuickOrder({
    required this.id,
    required this.custId,
    required this.custPhone,
    required this.productId,
    required this.quantity,
    required this.table,
    required this.createdAt,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          custId == other.custId &&
          custPhone == other.custPhone &&
          productId == other.productId &&
          quantity == other.quantity &&
          table == other.table &&
          createdAt == other.createdAt &&
          status == other.status);

  @override
  int get hashCode =>
      id.hashCode ^
      custId.hashCode ^
      custPhone.hashCode ^
      productId.hashCode ^
      quantity.hashCode ^
      table.hashCode ^
      createdAt.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'QuickOrder{' +
        ' id: $id,' +
        ' custId: $custId,' +
        ' custPhone: $custPhone,' +
        ' productId: $productId,' +
        ' quantity: $quantity,' +
        ' table: $table,' +
        ' createdAt: $createdAt,' +
        ' status: $status,' +
        '}';
  }

  QuickOrder copyWith({
    String? id,
    String? custId,
    int? custPhone,
    String? productId,
    int? quantity,
    String? table,
    int? createdAt,
    String? status,
  }) {
    return QuickOrder(
      id: id ?? this.id,
      custId: custId ?? this.custId,
      custPhone: custPhone ?? this.custPhone,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      table: table ?? this.table,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'custId': this.custId,
      'custPhone': this.custPhone,
      'productId': this.productId,
      'quantity': this.quantity,
      'table': this.table,
      'createdAt': this.createdAt,
      'status': this.status,
    };
  }

  factory QuickOrder.fromMap(Map<String, dynamic> map) {
    return QuickOrder(
      id: map['id'] as String,
      custId: map['custId'] as String,
      custPhone: map['custPhone'] as int,
      productId: map['productId'] as String,
      quantity: map['quantity'] as int,
      table: map['table'] as String,
      createdAt: map['createdAt'] as int,
      status: map['status'] as String,
    );
  }

//</editor-fold>
}