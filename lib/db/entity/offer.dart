class Offer {
  final String id;
  final String blocId;
  final String productId;
  final String productName;
  final String description;
  final bool isPrivateOffer;
  final bool isCommunityOffer;
  final double offerPercent;
  final double offerPricePrivate;
  final double offerPriceCommunity;
  bool isActive;
  final int creationTime;
  final int endTime;

//<editor-fold desc="Data Methods">

  Offer({
    required this.id,
    required this.blocId,
    required this.productId,
    required this.productName,
    required this.description,
    required this.isPrivateOffer,
    required this.isCommunityOffer,
    required this.offerPercent,
    required this.offerPricePrivate,
    required this.offerPriceCommunity,
    required this.isActive,
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
          description == other.description &&
          isPrivateOffer == other.isPrivateOffer &&
          isCommunityOffer == other.isCommunityOffer &&
          offerPercent == other.offerPercent &&
          offerPricePrivate == other.offerPricePrivate &&
          offerPriceCommunity == other.offerPriceCommunity &&
          isActive == other.isActive &&
          creationTime == other.creationTime &&
          endTime == other.endTime);

  @override
  int get hashCode =>
      id.hashCode ^
      blocId.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      description.hashCode ^
      isPrivateOffer.hashCode ^
      isCommunityOffer.hashCode ^
      offerPercent.hashCode ^
      offerPricePrivate.hashCode ^
      offerPriceCommunity.hashCode ^
      isActive.hashCode ^
      creationTime.hashCode ^
      endTime.hashCode;

  @override
  String toString() {
    return 'Offer{' +
        ' id: $id,' +
        ' blocId: $blocId,' +
        ' productId: $productId,' +
        ' productName: $productName,' +
        ' description: $description,' +
        ' isPrivateOffer: $isPrivateOffer,' +
        ' isCommunityOffer: $isCommunityOffer,' +
        ' offerPercent: $offerPercent,' +
        ' offerPricePrivate: $offerPricePrivate,' +
        ' offerPriceCommunity: $offerPriceCommunity,' +
        ' isActive: $isActive,' +
        ' creationTime: $creationTime,' +
        ' endTime: $endTime,' +
        '}';
  }

  Offer copyWith({
    String? id,
    String? blocId,
    String? productId,
    String? productName,
    String? description,
    bool? isPrivateOffer,
    bool? isCommunityOffer,
    double? offerPercent,
    double? offerPricePrivate,
    double? offerPriceCommunity,
    bool? isActive,
    int? creationTime,
    int? endTime,
  }) {
    return Offer(
      id: id ?? this.id,
      blocId: blocId ?? this.blocId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      isPrivateOffer: isPrivateOffer ?? this.isPrivateOffer,
      isCommunityOffer: isCommunityOffer ?? this.isCommunityOffer,
      offerPercent: offerPercent ?? this.offerPercent,
      offerPricePrivate: offerPricePrivate ?? this.offerPricePrivate,
      offerPriceCommunity: offerPriceCommunity ?? this.offerPriceCommunity,
      isActive: isActive ?? this.isActive,
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
      'description': this.description,
      'isPrivateOffer': this.isPrivateOffer,
      'isCommunityOffer': this.isCommunityOffer,
      'offerPercent': this.offerPercent,
      'offerPricePrivate': this.offerPricePrivate,
      'offerPriceCommunity': this.offerPriceCommunity,
      'isActive': this.isActive,
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
      description: map['description'] as String,
      isPrivateOffer: map['isPrivateOffer'] as bool,
      isCommunityOffer: map['isCommunityOffer'] as bool,
      offerPercent: map['offerPercent'] as double,
      offerPricePrivate: map['offerPricePrivate'] as double,
      offerPriceCommunity: map['offerPriceCommunity'] as double,
      isActive: map['isActive'] as bool,
      creationTime: map['creationTime'] as int,
      endTime: map['endTime'] as int,
    );
  }

//</editor-fold>
}