class Ad {
  final String id;
  final String title;
  final String message;
  final String blocId;
  final int hits;
  final int createdAt;
  final String imageUrl;
  final bool isActive;

  final String partyName;
  final String partyChapter;

//<editor-fold desc="Data Methods">
  const Ad({
    required this.id,
    required this.title,
    required this.message,
    required this.blocId,
    required this.hits,
    required this.createdAt,
    required this.imageUrl,
    required this.isActive,
    required this.partyName,
    required this.partyChapter,
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
          imageUrl == other.imageUrl &&
          isActive == other.isActive &&
          partyName == other.partyName &&
          partyChapter == other.partyChapter);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      message.hashCode ^
      blocId.hashCode ^
      hits.hashCode ^
      createdAt.hashCode ^
      imageUrl.hashCode ^
      isActive.hashCode ^
      partyName.hashCode ^
      partyChapter.hashCode;

  @override
  String toString() {
    return 'Ad{' +
        ' id: $id,' +
        ' title: $title,' +
        ' message: $message,' +
        ' blocId: $blocId,' +
        ' hits: $hits,' +
        ' createdAt: $createdAt,' +
        ' imageUrl: $imageUrl,' +
        ' isActive: $isActive,' +
        ' partyName: $partyName,' +
        ' partyChapter: $partyChapter,' +
        '}';
  }

  Ad copyWith({
    String? id,
    String? title,
    String? message,
    String? blocId,
    int? hits,
    int? createdAt,
    String? imageUrl,
    bool? isActive,
    String? partyName,
    String? partyChapter,
  }) {
    return Ad(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      blocId: blocId ?? this.blocId,
      hits: hits ?? this.hits,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      partyName: partyName ?? this.partyName,
      partyChapter: partyChapter ?? this.partyChapter,
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
      'imageUrl': this.imageUrl,
      'isActive': this.isActive,
      'partyName': this.partyName,
      'partyChapter': this.partyChapter,
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
      imageUrl: map['imageUrl'] as String,
      isActive: map['isActive'] as bool,
      partyName: map['partyName'] as String,
      partyChapter: map['partyChapter'] as String,
    );
  }

//</editor-fold>
}