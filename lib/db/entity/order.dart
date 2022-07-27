//todo: implementation is saved for another day
class Order {
  final String id;
  final String customerId;
  final String blocId;
  final bool isCommunity;
  final int sequence;
  final List<String> cartIds;
  final double amount;
  final int creationTime;
  final int completionTime;

//<editor-fold desc="Data Methods">

  const Order({
    required this.id,
    required this.customerId,
    required this.blocId,
    required this.isCommunity,
    required this.sequence,
    required this.cartIds,
    required this.amount,
    required this.creationTime,
    required this.completionTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          blocId == other.blocId &&
          isCommunity == other.isCommunity &&
          sequence == other.sequence &&
          cartIds == other.cartIds &&
          amount == other.amount &&
          creationTime == other.creationTime &&
          completionTime == other.completionTime);

  @override
  int get hashCode =>
      id.hashCode ^
      customerId.hashCode ^
      blocId.hashCode ^
      isCommunity.hashCode ^
      sequence.hashCode ^
      cartIds.hashCode ^
      amount.hashCode ^
      creationTime.hashCode ^
      completionTime.hashCode;

  @override
  String toString() {
    return 'Order{' +
        ' id: $id,' +
        ' customerId: $customerId,' +
        ' blocId: $blocId,' +
        ' isCommunity: $isCommunity,' +
        ' sequence: $sequence,' +
        ' cartIds: $cartIds,' +
        ' amount: $amount,' +
        ' creationTime: $creationTime,' +
        ' completionTime: $completionTime,' +
        '}';
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? blocId,
    bool? isCommunity,
    int? sequence,
    List<String>? cartIds,
    double? amount,
    int? creationTime,
    int? completionTime,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      blocId: blocId ?? this.blocId,
      isCommunity: isCommunity ?? this.isCommunity,
      sequence: sequence ?? this.sequence,
      cartIds: cartIds ?? this.cartIds,
      amount: amount ?? this.amount,
      creationTime: creationTime ?? this.creationTime,
      completionTime: completionTime ?? this.completionTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'customerId': this.customerId,
      'blocId': this.blocId,
      'isCommunity': this.isCommunity,
      'sequence': this.sequence,
      'cartIds': this.cartIds,
      'amount': this.amount,
      'creationTime': this.creationTime,
      'completionTime': this.completionTime,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      blocId: map['blocId'] as String,
      isCommunity: map['isCommunity'] as bool,
      sequence: map['sequence'] as int,
      cartIds: map['cartIds'] as List<String>,
      amount: map['amount'] as double,
      creationTime: map['creationTime'] as int,
      completionTime: map['completionTime'] as int,
    );
  }

//</editor-fold>
}