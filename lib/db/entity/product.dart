class Product {
  final String id;
  final String name;
  final String type;
  final String category;
  final String description;
  final double price;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final int createdAt;
  final bool isAvailable;
  final double priceHighest;
  final double priceLowest;
  final int priceHighestTime;
  final int priceLowestTime;
  final double priceCommunity;
  bool isOfferRunning;
  final bool isVeg;
  List<String> blocIds;

//<editor-fold desc="Data Methods">

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.price,
    required this.serviceId,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
    required this.isAvailable,
    required this.priceHighest,
    required this.priceLowest,
    required this.priceHighestTime,
    required this.priceLowestTime,
    required this.priceCommunity,
    required this.isOfferRunning,
    required this.isVeg,
    required this.blocIds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          category == other.category &&
          description == other.description &&
          price == other.price &&
          serviceId == other.serviceId &&
          imageUrl == other.imageUrl &&
          ownerId == other.ownerId &&
          createdAt == other.createdAt &&
          isAvailable == other.isAvailable &&
          priceHighest == other.priceHighest &&
          priceLowest == other.priceLowest &&
          priceHighestTime == other.priceHighestTime &&
          priceLowestTime == other.priceLowestTime &&
          priceCommunity == other.priceCommunity &&
          isOfferRunning == other.isOfferRunning &&
          isVeg == other.isVeg &&
          blocIds == other.blocIds);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      category.hashCode ^
      description.hashCode ^
      price.hashCode ^
      serviceId.hashCode ^
      imageUrl.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode ^
      isAvailable.hashCode ^
      priceHighest.hashCode ^
      priceLowest.hashCode ^
      priceHighestTime.hashCode ^
      priceLowestTime.hashCode ^
      priceCommunity.hashCode ^
      isOfferRunning.hashCode ^
      isVeg.hashCode ^
      blocIds.hashCode;

  @override
  String toString() {
    return 'Product{' +
        ' id: $id,' +
        ' name: $name,' +
        ' type: $type,' +
        ' category: $category,' +
        ' description: $description,' +
        ' price: $price,' +
        ' serviceId: $serviceId,' +
        ' imageUrl: $imageUrl,' +
        ' ownerId: $ownerId,' +
        ' createdAt: $createdAt,' +
        ' isAvailable: $isAvailable,' +
        ' priceHighest: $priceHighest,' +
        ' priceLowest: $priceLowest,' +
        ' priceHighestTime: $priceHighestTime,' +
        ' priceLowestTime: $priceLowestTime,' +
        ' priceCommunity: $priceCommunity,' +
        ' isOfferRunning: $isOfferRunning,' +
        ' isVeg: $isVeg,' +
        ' blocIds: $blocIds,' +
        '}';
  }

  Product copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    String? description,
    double? price,
    String? serviceId,
    String? imageUrl,
    String? ownerId,
    int? createdAt,
    bool? isAvailable,
    double? priceHighest,
    double? priceLowest,
    int? priceHighestTime,
    int? priceLowestTime,
    double? priceCommunity,
    bool? isOfferRunning,
    bool? isVeg,
    List<String>? blocIds,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      serviceId: serviceId ?? this.serviceId,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      isAvailable: isAvailable ?? this.isAvailable,
      priceHighest: priceHighest ?? this.priceHighest,
      priceLowest: priceLowest ?? this.priceLowest,
      priceHighestTime: priceHighestTime ?? this.priceHighestTime,
      priceLowestTime: priceLowestTime ?? this.priceLowestTime,
      priceCommunity: priceCommunity ?? this.priceCommunity,
      isOfferRunning: isOfferRunning ?? this.isOfferRunning,
      isVeg: isVeg ?? this.isVeg,
      blocIds: blocIds ?? this.blocIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
      'category': this.category,
      'description': this.description,
      'price': this.price,
      'serviceId': this.serviceId,
      'imageUrl': this.imageUrl,
      'ownerId': this.ownerId,
      'createdAt': this.createdAt,
      'isAvailable': this.isAvailable,
      'priceHighest': this.priceHighest,
      'priceLowest': this.priceLowest,
      'priceHighestTime': this.priceHighestTime,
      'priceLowestTime': this.priceLowestTime,
      'priceCommunity': this.priceCommunity,
      'isOfferRunning': this.isOfferRunning,
      'isVeg': this.isVeg,
      'blocIds': this.blocIds,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    double price = 0.0;
    int intPrice = 0;
    double priceHighest = 0.0;
    double priceLowest = 0.0;
    double priceCommunity = 0.0;

    try {
      price = (map['price'] as double);
    } catch (err) {
      intPrice = map['price'] as int;
      price = intPrice.toDouble();
    }

    try {
      priceHighest = (map['priceHighest'] as double);
    } catch (err) {
      intPrice = map['priceHighest'] as int;
      priceHighest = intPrice.toDouble();
    }

    try {
      priceLowest = (map['priceLowest'] as double);
    } catch (err) {
      intPrice = map['priceLowest'] as int;
      priceLowest = intPrice.toDouble();
    }

    try {
      priceCommunity = (map['priceCommunity'] as double);
    } catch (err) {
      intPrice = map['priceCommunity'] as int;
      priceCommunity = intPrice.toDouble();
    }

    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      price: price,
      serviceId: map['serviceId'] as String,
      imageUrl: map['imageUrl'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: map['createdAt'] as int,
      isAvailable: map['isAvailable'] as bool,
      priceHighest: priceHighest,
      priceLowest: priceLowest,
      priceHighestTime: map['priceHighestTime'] as int,
      priceLowestTime: map['priceLowestTime'] as int,
      priceCommunity: priceCommunity,
      isOfferRunning: map['isOfferRunning'] as bool,
      isVeg: map['isVeg'] as bool,
      blocIds: map['blocIds'] as List<String>,
    );
  }

//</editor-fold>
}
