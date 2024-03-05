class Advert{
  String id;
  String ownerId;
  String name;
  List<String> imageUrls;
  String linkUrl;
  int clickCount;
  int views;
  bool isActive;

  int startTime;
  int endTime;

//<editor-fold desc="Data Methods">
  Advert({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.imageUrls,
    required this.linkUrl,
    required this.clickCount,
    required this.views,
    required this.isActive,
    required this.startTime,
    required this.endTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Advert &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ownerId == other.ownerId &&
          name == other.name &&
          imageUrls == other.imageUrls &&
          linkUrl == other.linkUrl &&
          clickCount == other.clickCount &&
          views == other.views &&
          isActive == other.isActive &&
          startTime == other.startTime &&
          endTime == other.endTime);

  @override
  int get hashCode =>
      id.hashCode ^
      ownerId.hashCode ^
      name.hashCode ^
      imageUrls.hashCode ^
      linkUrl.hashCode ^
      clickCount.hashCode ^
      views.hashCode ^
      isActive.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;

  @override
  String toString() {
    return 'Advert{' +
        ' id: $id,' +
        ' ownerId: $ownerId,' +
        ' name: $name,' +
        ' imageUrls: $imageUrls,' +
        ' linkUrl: $linkUrl,' +
        ' clickCount: $clickCount,' +
        ' views: $views,' +
        ' isActive: $isActive,' +
        ' startTime: $startTime,' +
        ' endTime: $endTime,' +
        '}';
  }

  Advert copyWith({
    String? id,
    String? ownerId,
    String? name,
    List<String>? imageUrls,
    String? linkUrl,
    int? clickCount,
    int? views,
    bool? isActive,
    int? startTime,
    int? endTime,
  }) {
    return Advert(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrl: linkUrl ?? this.linkUrl,
      clickCount: clickCount ?? this.clickCount,
      views: views ?? this.views,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'ownerId': this.ownerId,
      'name': this.name,
      'imageUrls': this.imageUrls,
      'linkUrl': this.linkUrl,
      'clickCount': this.clickCount,
      'views': this.views,
      'isActive': this.isActive,
      'startTime': this.startTime,
      'endTime': this.endTime,
    };
  }

  factory Advert.fromMap(Map<String, dynamic> map) {
    return Advert(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      imageUrls: map['imageUrls'] as List<String>,
      linkUrl: map['linkUrl'] as String,
      clickCount: map['clickCount'] as int,
      views: map['views'] as int,
      isActive: map['isActive'] as bool,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
    );
  }

//</editor-fold>
}