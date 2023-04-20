
class Bloc {
  final String id;
  final String name;
  final String cityId;
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String ownerId;
  final String createdAt;
  final bool isActive;
  final String imageUrl;
  final List<String> imageUrls;

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
    required this.imageUrl,
    required this.imageUrls,
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
          imageUrl == other.imageUrl &&
          imageUrls == other.imageUrls);

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
      imageUrl.hashCode ^
      imageUrls.hashCode;

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
        ' imageUrl: $imageUrl,' +
        ' imageUrls: $imageUrls,' +
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
    String? imageUrl,
    List<String>? imageUrls,
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
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
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
      'imageUrl': this.imageUrl,
      'imageUrls': this.imageUrls,
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
      imageUrl: map['imageUrl'] as String,
      imageUrls: map['imageUrls'] as List<String>,
    );
  }

//</editor-fold>
}
