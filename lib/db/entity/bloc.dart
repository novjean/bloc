import 'package:floor/floor.dart';

@entity
class Bloc {
  @primaryKey
  final String id;
  final String name;
  final String city;
  final String addressLine1;
  final String addressLine2;
  final String pinCode;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

//<editor-fold desc="Data Methods">

  Bloc({
    required this.id,
    required this.name,
    required this.city,
    required this.addressLine1,
    required this.addressLine2,
    required this.pinCode,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bloc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          city == other.city &&
          addressLine1 == other.addressLine1 &&
          addressLine2 == other.addressLine2 &&
          pinCode == other.pinCode &&
          imageUrl == other.imageUrl &&
          ownerId == other.ownerId &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      city.hashCode ^
      addressLine1.hashCode ^
      addressLine2.hashCode ^
      pinCode.hashCode ^
      imageUrl.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'Bloc{' +
        ' id: $id,' +
        ' name: $name,' +
        ' cityId: $city,' +
        ' addressLine1: $addressLine1,' +
        ' addressLine2: $addressLine2,' +
        ' pinCode: $pinCode,' +
        ' imageUrl: $imageUrl,' +
        ' ownerId: $ownerId,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  Bloc copyWith({
    String? id,
    String? name,
    String? city,
    String? addressLine1,
    String? addressLine2,
    String? pinCode,
    String? imageUrl,
    String? ownerId,
    String? createdAt,
  }) {
    return Bloc(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      pinCode: pinCode ?? this.pinCode,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blocId': this.id,
      'name': this.name,
      'city': this.city,
      'addressLine1': this.addressLine1,
      'addressLine2': this.addressLine2,
      'pinCode': this.pinCode,
      'imageUrl': this.imageUrl,
      'ownerId': this.ownerId,
      'createdAt': this.createdAt,
    };
  }

  factory Bloc.fromMap(Map<String, dynamic> map) {
    return Bloc(
      id: map['blocId'] as String,
      name: map['name'] as String,
      city: map['city'] as String,
      addressLine1: map['addressLine1'] as String,
      addressLine2: map['addressLine2'] as String,
      pinCode: map['pinCode'] as String,
      imageUrl: map['imageUrl'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

//</editor-fold>
}
