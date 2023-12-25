class Bloc {
  final String id;
  final String name;
  final String cityId;
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String ownerId;
  final String createdAt;
  final bool isActive; // not using this field yet
  final List<String> imageUrls;

  final double latitude;
  final double longitude;
  final String mapImageUrl;

//<editor-fold desc="Data Methods">
  const Bloc({
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
          mapImageUrl == other.mapImageUrl);

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
      mapImageUrl.hashCode;

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
    );
  }

//</editor-fold>
}
