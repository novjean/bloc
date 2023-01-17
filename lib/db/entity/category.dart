
class Category {
  final String id;
  final String name;
  final String type;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final int createdAt;
  final int sequence;

//<editor-fold desc="Data Methods">

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.serviceId,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
    required this.sequence,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          serviceId == other.serviceId &&
          imageUrl == other.imageUrl &&
          ownerId == other.ownerId &&
          createdAt == other.createdAt &&
          sequence == other.sequence);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      serviceId.hashCode ^
      imageUrl.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode ^
      sequence.hashCode;

  @override
  String toString() {
    return 'Category{' +
        ' id: $id,' +
        ' name: $name,' +
        ' type: $type,' +
        ' serviceId: $serviceId,' +
        ' imageUrl: $imageUrl,' +
        ' ownerId: $ownerId,' +
        ' createdAt: $createdAt,' +
        ' sequence: $sequence,' +
        '}';
  }

  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? serviceId,
    String? imageUrl,
    String? ownerId,
    int? createdAt,
    int? sequence,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      serviceId: serviceId ?? this.serviceId,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      sequence: sequence ?? this.sequence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
      'serviceId': this.serviceId,
      'imageUrl': this.imageUrl,
      'ownerId': this.ownerId,
      'createdAt': this.createdAt,
      'sequence': this.sequence,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      serviceId: map['serviceId'] as String,
      imageUrl: map['imageUrl'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: map['createdAt'] as int,
      sequence: map['sequence'] as int,
    );
  }

//</editor-fold>
}