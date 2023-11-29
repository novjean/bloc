class AdCampaign{
  String id;
  String name;
  List<String> imageUrls;
  String linkUrl;
  int adClick;
  bool isActive;

  bool isStorySize;

//<editor-fold desc="Data Methods">
  AdCampaign({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.linkUrl,
    required this.adClick,
    required this.isActive,
    required this.isStorySize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdCampaign &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imageUrls == other.imageUrls &&
          linkUrl == other.linkUrl &&
          adClick == other.adClick &&
          isActive == other.isActive &&
          isStorySize == other.isStorySize);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      imageUrls.hashCode ^
      linkUrl.hashCode ^
      adClick.hashCode ^
      isActive.hashCode ^
      isStorySize.hashCode;

  @override
  String toString() {
    return 'AdCampaign{' +
        ' id: $id,' +
        ' name: $name,' +
        ' imageUrls: $imageUrls,' +
        ' linkUrl: $linkUrl,' +
        ' adClick: $adClick,' +
        ' isActive: $isActive,' +
        ' isStorySize: $isStorySize,' +
        '}';
  }

  AdCampaign copyWith({
    String? id,
    String? name,
    List<String>? imageUrls,
    String? linkUrl,
    int? adClick,
    bool? isActive,
    bool? isStorySize,
  }) {
    return AdCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrl: linkUrl ?? this.linkUrl,
      adClick: adClick ?? this.adClick,
      isActive: isActive ?? this.isActive,
      isStorySize: isStorySize ?? this.isStorySize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'imageUrls': this.imageUrls,
      'linkUrl': this.linkUrl,
      'adClick': this.adClick,
      'isActive': this.isActive,
      'isStorySize': this.isStorySize,
    };
  }

  factory AdCampaign.fromMap(Map<String, dynamic> map) {
    return AdCampaign(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrls: map['imageUrls'] as List<String>,
      linkUrl: map['linkUrl'] as String,
      adClick: map['adClick'] as int,
      isActive: map['isActive'] as bool,
      isStorySize: map['isStorySize'] as bool,
    );
  }

//</editor-fold>
}