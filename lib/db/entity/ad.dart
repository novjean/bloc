class Ad {
  final String id;
  final String title;
  final String message;
  final String blocId;
  final int hits;
  final int createdAt;
  final bool isActive;

//<editor-fold desc="Data Methods">
  const Ad({
    required this.id,
    required this.title,
    required this.message,
    required this.blocId,
    required this.hits,
    required this.createdAt,
    required this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ad &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          message == other.message &&
          blocId == other.blocId &&
          hits == other.hits &&
          createdAt == other.createdAt &&
          isActive == other.isActive);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      message.hashCode ^
      blocId.hashCode ^
      hits.hashCode ^
      createdAt.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'Ad{' +
        ' id: $id,' +
        ' title: $title,' +
        ' message: $message,' +
        ' blocId: $blocId,' +
        ' hits: $hits,' +
        ' createdAt: $createdAt,' +
        ' isActive: $isActive,' +
        '}';
  }

  Ad copyWith({
    String? id,
    String? title,
    String? message,
    String? blocId,
    int? hits,
    int? createdAt,
    bool? isActive,
  }) {
    return Ad(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      blocId: blocId ?? this.blocId,
      hits: hits ?? this.hits,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'message': this.message,
      'blocId': this.blocId,
      'hits': this.hits,
      'createdAt': this.createdAt,
      'isActive': this.isActive,
    };
  }

  factory Ad.fromMap(Map<String, dynamic> map) {
    return Ad(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      blocId: map['blocId'] as String,
      hits: map['hits'] as int,
      createdAt: map['createdAt'] as int,
      isActive: map['isActive'] as bool,
    );
  }

//</editor-fold>
}