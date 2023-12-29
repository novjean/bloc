class Bloc {
  final String id;
  final String name;
  final String cityId;
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String ownerId;
  final String createdAt;

  // this field is used to determine which blocs get shown in home
  final bool isActive;

  final List<String> imageUrls;

  final double latitude;
  final double longitude;
  final String mapImageUrl;

  final int orderPriority;
  final bool powerBloc;
  final bool superPowerBloc;
  final int creationDate;

//<editor-fold desc="Data Methods">
  Bloc({
    required this.id,
    required this.name,
    required this.cityId,
    required this.addressLine1,
    required this.addressLine2,
    required this.pinCode,
    required this.ownerId,
    required this.createdAt,
    required this.isActive,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.mapImageUrl,
    required this.orderPriority,
    required this.powerBloc,
    required this.superPowerBloc,
    required this.creationDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bloc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          cityId == other.cityId &&
          addressLine1 == other.addressLine1 &&
          addressLine2 == other.addressLine2 &&
          pinCode == other.pinCode &&
          ownerId == other.ownerId &&
          createdAt == other.createdAt &&
          isActive == other.isActive &&
          imageUrls == other.imageUrls &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          mapImageUrl == other.mapImageUrl &&
          orderPriority == other.orderPriority &&
          powerBloc == other.powerBloc &&
          superPowerBloc == other.superPowerBloc &&
          creationDate == other.creationDate);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      cityId.hashCode ^
      addressLine1.hashCode ^
      addressLine2.hashCode ^
      pinCode.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode ^
      isActive.hashCode ^
      imageUrls.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      mapImageUrl.hashCode ^
      orderPriority.hashCode ^
      powerBloc.hashCode ^
      superPowerBloc.hashCode ^
      creationDate.hashCode;

  @override
  String toString() {
    return 'Bloc{' +
        ' id: $id,' +
        ' name: $name,' +
        ' cityId: $cityId,' +
        ' addressLine1: $addressLine1,' +
        ' addressLine2: $addressLine2,' +
        ' pinCode: $pinCode,' +
        ' ownerId: $ownerId,' +
        ' createdAt: $createdAt,' +
        ' isActive: $isActive,' +
        ' imageUrls: $imageUrls,' +
        ' latitude: $latitude,' +
        ' longitude: $longitude,' +
        ' mapImageUrl: $mapImageUrl,' +
        ' orderPriority: $orderPriority,' +
        ' powerBloc: $powerBloc,' +
        ' superPowerBloc: $superPowerBloc,' +
        ' creationDate: $creationDate,' +
        '}';
  }

  Bloc copyWith({
    String? id,
    String? name,
    String? cityId,
    String? addressLine1,
    String? addressLine2,
    String? pinCode,
    String? ownerId,
    String? createdAt,
    bool? isActive,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    String? mapImageUrl,
    int? orderPriority,
    bool? powerBloc,
    bool? superPowerBloc,
    int? creationDate,
  }) {
    return Bloc(
      id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      pinCode: pinCode ?? this.pinCode,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
      orderPriority: orderPriority ?? this.orderPriority,
      powerBloc: powerBloc ?? this.powerBloc,
      superPowerBloc: superPowerBloc ?? this.superPowerBloc,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'cityId': this.cityId,
      'addressLine1': this.addressLine1,
      'addressLine2': this.addressLine2,
      'pinCode': this.pinCode,
      'ownerId': this.ownerId,
      'createdAt': this.createdAt,
      'isActive': this.isActive,
      'imageUrls': this.imageUrls,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'mapImageUrl': this.mapImageUrl,
      'orderPriority': this.orderPriority,
      'powerBloc': this.powerBloc,
      'superPowerBloc': this.superPowerBloc,
      'creationDate': this.creationDate,
    };
  }

  factory Bloc.fromMap(Map<String, dynamic> map) {
    return Bloc(
      id: map['id'] as String,
      name: map['name'] as String,
      cityId: map['cityId'] as String,
      addressLine1: map['addressLine1'] as String,
      addressLine2: map['addressLine2'] as String,
      pinCode: map['pinCode'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: map['createdAt'] as String,
      isActive: map['isActive'] as bool,
      imageUrls: map['imageUrls'] as List<String>,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      mapImageUrl: map['mapImageUrl'] as String,
      orderPriority: map['orderPriority'] as int,
      powerBloc: map['powerBloc'] as bool,
      superPowerBloc: map['superPowerBloc'] as bool,
      creationDate: map['creationDate'] as int,
    );
  }

//</editor-fold>
}
