import 'package:floor/floor.dart';

@entity
class BlocService {
  @primaryKey
  final String id;
  final String name;
  final String blocId;
  final String type;
  final double primaryPhone;
  final double secondaryPhone;
  final String emailId;
  final String imageUrl;
  final String ownerId;
  final String createdAt;

//<editor-fold desc="Data Methods">

  const BlocService({
    required this.id,
    required this.name,
    required this.blocId,
    required this.type,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.emailId,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlocService &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          blocId == other.blocId &&
          type == other.type &&
          primaryPhone == other.primaryPhone &&
          secondaryPhone == other.secondaryPhone &&
          emailId == other.emailId &&
          imageUrl == other.imageUrl &&
          ownerId == other.ownerId &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      blocId.hashCode ^
      type.hashCode ^
      primaryPhone.hashCode ^
      secondaryPhone.hashCode ^
      emailId.hashCode ^
      imageUrl.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'BlocService{' +
        ' id: $id,' +
        ' name: $name,' +
        ' blocId: $blocId,' +
        ' type: $type,' +
        ' primaryPhone: $primaryPhone,' +
        ' secondaryPhone: $secondaryPhone,' +
        ' emailId: $emailId,' +
        ' imageUrl: $imageUrl,' +
        ' ownerId: $ownerId,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  BlocService copyWith({
    String? id,
    String? name,
    String? blocId,
    String? type,
    double? primaryPhone,
    double? secondaryPhone,
    String? emailId,
    String? imageUrl,
    String? ownerId,
    String? createdAt,
  }) {
    return BlocService(
      id: id ?? this.id,
      name: name ?? this.name,
      blocId: blocId ?? this.blocId,
      type: type ?? this.type,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      emailId: emailId ?? this.emailId,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'blocId': this.blocId,
      'type': this.type,
      'primaryPhone': this.primaryPhone,
      'secondaryPhone': this.secondaryPhone,
      'emailId': this.emailId,
      'imageUrl': this.imageUrl,
      'ownerId': this.ownerId,
      'createdAt': this.createdAt,
    };
  }

  factory BlocService.fromMap(Map<String, dynamic> map) {
    return BlocService(
      id: map['id'] as String,
      name: map['name'] as String,
      blocId: map['blocId'] as String,
      type: map['type'] as String,
      primaryPhone: double.parse(map['primaryPhone']),
      secondaryPhone: double.parse(map['secondaryPhone']),
      emailId: map['emailId'] as String,
      imageUrl: map['imageUrl'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

//</editor-fold>
}