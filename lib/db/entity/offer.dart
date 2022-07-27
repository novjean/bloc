class Offer {
  final String id;
  final String blocId;
  final String productId;
  final String productName;
  final bool isCommunity;
  final double discountPercent;
  final double newPrice;
  final int creationTime;
  final int endTime;

//<editor-fold desc="Data Methods">

  const Offer({
    required this.id,
    required this.blocId,
    required this.productId,
    required this.productName,
    required this.isCommunity,
    required this.discountPercent,
    required this.newPrice,
    required this.creationTime,
    required this.endTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Offer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blocId == other.blocId &&
          productId == other.productId &&
          productName == other.productName &&
          isCommunity == other.isCommunity &&
          discountPercent == other.discountPercent &&
          newPrice == other.newPrice &&
          creationTime == other.creationTime &&
          endTime == other.endTime);

  @override
  int get hashCode =>
      id.hashCode ^
      blocId.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      isCommunity.hashCode ^
      discountPercent.hashCode ^
      newPrice.hashCode ^
      creationTime.hashCode ^
      endTime.hashCode;

  @override
  String toString() {
    return 'Offer{' +
        ' id: $id,' +
        ' blocId: $blocId,' +
        ' productId: $productId,' +
        ' productName: $productName,' +
        ' isCommunity: $isCommunity,' +
        ' discountPercent: $discountPercent,' +
        ' newPrice: $newPrice,' +
        ' creationTime: $creationTime,' +
        ' endTime: $endTime,' +
        '}';
  }

  Offer copyWith({
    String? id,
    String? blocId,
    String? productId,
    String? productName,
    bool? isCommunity,
    double? discountPercent,
    double? newPrice,
    int? creationTime,
    int? endTime,
  }) {
    return Offer(
      id: id ?? this.id,
      blocId: blocId ?? this.blocId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      isCommunity: isCommunity ?? this.isCommunity,
      discountPercent: discountPercent ?? this.discountPercent,
      newPrice: newPrice ?? this.newPrice,
      creationTime: creationTime ?? this.creationTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'blocId': this.blocId,
      'productId': this.productId,
      'productName': this.productName,
      'isCommunity': this.isCommunity,
      'discountPercent': this.discountPercent,
      'newPrice': this.newPrice,
      'creationTime': this.creationTime,
      'endTime': this.endTime,
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] as String,
      blocId: map['blocId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      isCommunity: map['isCommunity'] as bool,
      discountPercent: map['discountPercent'] as double,
      newPrice: map['newPrice'] as double,
      creationTime: map['creationTime'] as int,
      endTime: map['endTime'] as int,
    );
  }

//</editor-fold>
}