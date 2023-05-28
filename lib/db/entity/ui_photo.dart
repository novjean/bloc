class UiPhoto {
  final String id;
  String name;
  final List<String> imageUrls;

//<editor-fold desc="Data Methods">
  UiPhoto({
    required this.id,
    required this.name,
    required this.imageUrls,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UiPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imageUrls == other.imageUrls);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ imageUrls.hashCode;

  @override
  String toString() {
    return 'UiPhoto{' +
        ' id: $id,' +
        ' name: $name,' +
        ' imageUrls: $imageUrls,' +
        '}';
  }

  UiPhoto copyWith({
    String? id,
    String? name,
    List<String>? imageUrls,
  }) {
    return UiPhoto(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'imageUrls': this.imageUrls,
    };
  }

  factory UiPhoto.fromMap(Map<String, dynamic> map) {
    return UiPhoto(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrls: map['imageUrls'] as List<String>,
    );
  }

//</editor-fold>
}