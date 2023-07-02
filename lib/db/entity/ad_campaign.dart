class AdCampaign{
  String id;
  String name;
  List<String> imageUrls;
  String linkUrl;
  int adClick;
  bool isActive;

//<editor-fold desc="Data Methods">
  AdCampaign({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.linkUrl,
    required this.adClick,
    required this.isActive,
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
          isActive == other.isActive);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      imageUrls.hashCode ^
      linkUrl.hashCode ^
      adClick.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'AdCampaign{' +
        ' id: $id,' +
        ' name: $name,' +
        ' imageUrls: $imageUrls,' +
        ' linkUrl: $linkUrl,' +
        ' adClick: $adClick,' +
        ' isActive: $isActive,' +
        '}';
  }

  AdCampaign copyWith({
    String? id,
    String? name,
    List<String>? imageUrls,
    String? linkUrl,
    int? adClick,
    bool? isActive,
  }) {
    return AdCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrl: linkUrl ?? this.linkUrl,
      adClick: adClick ?? this.adClick,
      isActive: isActive ?? this.isActive,
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
    );
  }

//</editor-fold>
}