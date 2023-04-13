
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
  final String imageUrl2;
  final String imageUrl3;

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
    required this.imageUrl2,
    required this.imageUrl3,
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
          imageUrl2 == other.imageUrl2 &&
          imageUrl3 == other.imageUrl3);

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
      imageUrl2.hashCode ^
      imageUrl3.hashCode;

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
        ' imageUrl2: $imageUrl2,' +
        ' imageUrl3: $imageUrl3,' +
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
    String? imageUrl2,
    String? imageUrl3,
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
      imageUrl2: imageUrl2 ?? this.imageUrl2,
      imageUrl3: imageUrl3 ?? this.imageUrl3,
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
      'imageUrl2': this.imageUrl2,
      'imageUrl3': this.imageUrl3,
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
      imageUrl2: map['imageUrl2'] as String,
      imageUrl3: map['imageUrl3'] as String,
    );
  }

//</editor-fold>
}
