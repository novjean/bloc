
class PartyPhoto {
  final String id;
  final String blocServiceId;
  final String partyName;
  final String loungeId;
  final String imageUrl;
  final String imageThumbUrl;
  final int createdAt;
  final int partyDate;
  final int endTime;
  List<String> likers;
  int initLikes;
  int downloadCount;
  List<String> downloaders;
  int views;
  final bool isFreePhoto;

  List<String> tags;

//<editor-fold desc="Data Methods">
  PartyPhoto({
    required this.id,
    required this.blocServiceId,
    required this.partyName,
    required this.loungeId,
    required this.imageUrl,
    required this.imageThumbUrl,
    required this.createdAt,
    required this.partyDate,
    required this.endTime,
    required this.likers,
    required this.initLikes,
    required this.downloadCount,
    required this.downloaders,
    required this.views,
    required this.isFreePhoto,
    required this.tags,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          blocServiceId == other.blocServiceId &&
          partyName == other.partyName &&
          loungeId == other.loungeId &&
          imageUrl == other.imageUrl &&
          imageThumbUrl == other.imageThumbUrl &&
          createdAt == other.createdAt &&
          partyDate == other.partyDate &&
          endTime == other.endTime &&
          likers == other.likers &&
          initLikes == other.initLikes &&
          downloadCount == other.downloadCount &&
          downloaders == other.downloaders &&
          views == other.views &&
          isFreePhoto == other.isFreePhoto &&
          tags == other.tags);

  @override
  int get hashCode =>
      id.hashCode ^
      blocServiceId.hashCode ^
      partyName.hashCode ^
      loungeId.hashCode ^
      imageUrl.hashCode ^
      imageThumbUrl.hashCode ^
      createdAt.hashCode ^
      partyDate.hashCode ^
      endTime.hashCode ^
      likers.hashCode ^
      initLikes.hashCode ^
      downloadCount.hashCode ^
      downloaders.hashCode ^
      views.hashCode ^
      isFreePhoto.hashCode ^
      tags.hashCode;

  @override
  String toString() {
    return 'PartyPhoto{' +
        ' id: $id,' +
        ' blocServiceId: $blocServiceId,' +
        ' partyName: $partyName,' +
        ' loungeId: $loungeId,' +
        ' imageUrl: $imageUrl,' +
        ' imageThumbUrl: $imageThumbUrl,' +
        ' createdAt: $createdAt,' +
        ' partyDate: $partyDate,' +
        ' endTime: $endTime,' +
        ' likers: $likers,' +
        ' initLikes: $initLikes,' +
        ' downloadCount: $downloadCount,' +
        ' downloaders: $downloaders,' +
        ' views: $views,' +
        ' isFreePhoto: $isFreePhoto,' +
        ' tags: $tags,' +
        '}';
  }

  PartyPhoto copyWith({
    String? id,
    String? blocServiceId,
    String? partyName,
    String? loungeId,
    String? imageUrl,
    String? imageThumbUrl,
    int? createdAt,
    int? partyDate,
    int? endTime,
    List<String>? likers,
    int? initLikes,
    int? downloadCount,
    List<String>? downloaders,
    int? views,
    bool? isFreePhoto,
    List<String>? tags,
  }) {
    return PartyPhoto(
      id: id ?? this.id,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      partyName: partyName ?? this.partyName,
      loungeId: loungeId ?? this.loungeId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageThumbUrl: imageThumbUrl ?? this.imageThumbUrl,
      createdAt: createdAt ?? this.createdAt,
      partyDate: partyDate ?? this.partyDate,
      endTime: endTime ?? this.endTime,
      likers: likers ?? this.likers,
      initLikes: initLikes ?? this.initLikes,
      downloadCount: downloadCount ?? this.downloadCount,
      downloaders: downloaders ?? this.downloaders,
      views: views ?? this.views,
      isFreePhoto: isFreePhoto ?? this.isFreePhoto,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'blocServiceId': this.blocServiceId,
      'partyName': this.partyName,
      'loungeId': this.loungeId,
      'imageUrl': this.imageUrl,
      'imageThumbUrl': this.imageThumbUrl,
      'createdAt': this.createdAt,
      'partyDate': this.partyDate,
      'endTime': this.endTime,
      'likers': this.likers,
      'initLikes': this.initLikes,
      'downloadCount': this.downloadCount,
      'downloaders': this.downloaders,
      'views': this.views,
      'isFreePhoto': this.isFreePhoto,
      'tags': this.tags,
    };
  }

  factory PartyPhoto.fromMap(Map<String, dynamic> map) {
    return PartyPhoto(
      id: map['id'] as String,
      blocServiceId: map['blocServiceId'] as String,
      partyName: map['partyName'] as String,
      loungeId: map['loungeId'] as String,
      imageUrl: map['imageUrl'] as String,
      imageThumbUrl: map['imageThumbUrl'] as String,
      createdAt: map['createdAt'] as int,
      partyDate: map['partyDate'] as int,
      endTime: map['endTime'] as int,
      likers: map['likers'] as List<String>,
      initLikes: map['initLikes'] as int,
      downloadCount: map['downloadCount'] as int,
      downloaders: map['downloaders'] as List<String>,
      views: map['views'] as int,
      isFreePhoto: map['isFreePhoto'] as bool,
      tags: map['tags'] as List<String>,
    );
  }

//</editor-fold>
}