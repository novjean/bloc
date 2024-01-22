class Organizer {
  final String id;
  final String name;
  final int phoneNumber;
  final String ownerId;
  final String imageUrl;
  final int createdAt;

//<editor-fold desc="Data Methods">
  const Organizer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.ownerId,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Organizer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          ownerId == other.ownerId &&
          imageUrl == other.imageUrl &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      ownerId.hashCode ^
      imageUrl.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'Organizer{' +
        ' id: $id,' +
        ' name: $name,' +
        ' phoneNumber: $phoneNumber,' +
        ' ownerId: $ownerId,' +
        ' imageUrl: $imageUrl,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  Organizer copyWith({
    String? id,
    String? name,
    int? phoneNumber,
    String? ownerId,
    String? imageUrl,
    int? createdAt,
  }) {
    return Organizer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      ownerId: ownerId ?? this.ownerId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'phoneNumber': this.phoneNumber,
      'ownerId': this.ownerId,
      'imageUrl': this.imageUrl,
      'createdAt': this.createdAt,
    };
  }

  factory Organizer.fromMap(Map<String, dynamic> map) {
    return Organizer(
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as int,
      ownerId: map['ownerId'] as String,
      imageUrl: map['imageUrl'] as String,
      createdAt: map['createdAt'] as int,
    );
  }

//</editor-fold>
}