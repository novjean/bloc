class AdCampaign{
  String id;
  String name;
  List<String> imageUrls;
  String linkUrl;
  int adClick;
  bool isActive;

  bool isStorySize;
  bool isPartyAd;
  String partyId;
  int endTime;

//<editor-fold desc="Data Methods">
  AdCampaign({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.linkUrl,
    required this.adClick,
    required this.isActive,
    required this.isStorySize,
    required this.isPartyAd,
    required this.partyId,
    required this.endTime,
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
          isStorySize == other.isStorySize &&
          isPartyAd == other.isPartyAd &&
          partyId == other.partyId &&
          endTime == other.endTime);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      imageUrls.hashCode ^
      linkUrl.hashCode ^
      adClick.hashCode ^
      isActive.hashCode ^
      isStorySize.hashCode ^
      isPartyAd.hashCode ^
      partyId.hashCode ^
      endTime.hashCode;

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
        ' isPartyAd: $isPartyAd,' +
        ' partyId: $partyId,' +
        ' endTime: $endTime,' +
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
    bool? isPartyAd,
    String? partyId,
    int? endTime,
  }) {
    return AdCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrl: linkUrl ?? this.linkUrl,
      adClick: adClick ?? this.adClick,
      isActive: isActive ?? this.isActive,
      isStorySize: isStorySize ?? this.isStorySize,
      isPartyAd: isPartyAd ?? this.isPartyAd,
      partyId: partyId ?? this.partyId,
      endTime: endTime ?? this.endTime,
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
      'isPartyAd': this.isPartyAd,
      'partyId': this.partyId,
      'endTime': this.endTime,
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
      isPartyAd: map['isPartyAd'] as bool,
      partyId: map['partyId'] as String,
      endTime: map['endTime'] as int,
    );
  }

//</editor-fold>
}