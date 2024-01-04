class City {
  final String id;
  final String name;
  final String ownerId;
  final String imageUrl;

//<editor-fold desc="Data Methods">
  const City({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is City &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ownerId == other.ownerId &&
          imageUrl == other.imageUrl);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ ownerId.hashCode ^ imageUrl.hashCode;

  @override
  String toString() {
    return 'City{' +
        ' id: $id,' +
        ' name: $name,' +
        ' ownerId: $ownerId,' +
        ' imageUrl: $imageUrl,' +
        '}';
  }

  City copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? imageUrl,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'ownerId': this.ownerId,
      'imageUrl': this.imageUrl,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] as String,
      name: map['name'] as String,
      ownerId: map['ownerId'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

//</editor-fold>
}
