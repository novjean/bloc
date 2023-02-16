class OrderBloc {
  final String id;
  final String customerId;
  final String blocServiceId;
  final String captainId;
  final bool isCommunity;
  final int sequence;
  final List<String> cartIds;
  final double amount;
  final int creationTime;
  final int completionTime;
  final int tableNumber;

//<editor-fold desc="Data Methods">

  const OrderBloc({
    required this.id,
    required this.customerId,
    required this.blocServiceId,
    required this.captainId,
    required this.isCommunity,
    required this.sequence,
    required this.cartIds,
    required this.amount,
    required this.creationTime,
    required this.completionTime,
    required this.tableNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderBloc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          blocServiceId == other.blocServiceId &&
          captainId == other.captainId &&
          isCommunity == other.isCommunity &&
          sequence == other.sequence &&
          cartIds == other.cartIds &&
          amount == other.amount &&
          creationTime == other.creationTime &&
          completionTime == other.completionTime &&
          tableNumber == other.tableNumber);

  @override
  int get hashCode =>
      id.hashCode ^
      customerId.hashCode ^
      blocServiceId.hashCode ^
      captainId.hashCode ^
      isCommunity.hashCode ^
      sequence.hashCode ^
      cartIds.hashCode ^
      amount.hashCode ^
      creationTime.hashCode ^
      completionTime.hashCode ^
      tableNumber.hashCode;

  @override
  String toString() {
    return 'OrderBloc{' +
        ' id: $id,' +
        ' customerId: $customerId,' +
        ' blocServiceId: $blocServiceId,' +
        ' captainId: $captainId,' +
        ' isCommunity: $isCommunity,' +
        ' sequence: $sequence,' +
        ' cartIds: $cartIds,' +
        ' amount: $amount,' +
        ' creationTime: $creationTime,' +
        ' completionTime: $completionTime,' +
        ' tableNumber: $tableNumber,' +
        '}';
  }

  OrderBloc copyWith({
    String? id,
    String? customerId,
    String? blocServiceId,
    String? captainId,
    bool? isCommunity,
    int? sequence,
    List<String>? cartIds,
    double? amount,
    int? creationTime,
    int? completionTime,
    int? tableNumber,
  }) {
    return OrderBloc(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      captainId: captainId ?? this.captainId,
      isCommunity: isCommunity ?? this.isCommunity,
      sequence: sequence ?? this.sequence,
      cartIds: cartIds ?? this.cartIds,
      amount: amount ?? this.amount,
      creationTime: creationTime ?? this.creationTime,
      completionTime: completionTime ?? this.completionTime,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'customerId': this.customerId,
      'blocServiceId': this.blocServiceId,
      'captainId': this.captainId,
      'isCommunity': this.isCommunity,
      'sequence': this.sequence,
      'cartIds': this.cartIds,
      'amount': this.amount,
      'creationTime': this.creationTime,
      'completionTime': this.completionTime,
      'tableNumber': this.tableNumber,
    };
  }

  factory OrderBloc.fromMap(Map<String, dynamic> map) {
    return OrderBloc(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      blocServiceId: map['blocServiceId'] as String,
      captainId: map['captainId'] as String,
      isCommunity: map['isCommunity'] as bool,
      sequence: map['sequence'] as int,
      cartIds: map['cartIds'] as List<String>,
      amount: map['amount'] as double,
      creationTime: map['creationTime'] as int,
      completionTime: map['completionTime'] as int,
      tableNumber: map['tableNumber'] as int,
    );
  }

//</editor-fold>
}