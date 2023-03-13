
class Category {
  final String id;
  final String name;
  final String type;
  final String serviceId;
  final String imageUrl;
  final String ownerId;
  final int createdAt;
  final int sequence;
  final String description;
  List<String> blocIds;

//<editor-fold desc="Data Methods">

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.serviceId,
    required this.imageUrl,
    required this.ownerId,
    required this.createdAt,
    required this.sequence,
    required this.description,
    required this.blocIds,
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
          sequence == other.sequence &&
          description == other.description &&
          blocIds == other.blocIds);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      serviceId.hashCode ^
      imageUrl.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode ^
      sequence.hashCode ^
      description.hashCode ^
      blocIds.hashCode;

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
        ' description: $description,' +
        ' blocIds: $blocIds,' +
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
    String? description,
    List<String>? blocIds,
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
      description: description ?? this.description,
      blocIds: blocIds ?? this.blocIds,
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
      'description': this.description,
      'blocIds': this.blocIds,
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
      description: map['description'] as String,
      blocIds: map['blocIds'] as List<String>,
    );
  }

//</editor-fold>
}