
class PartyPhoto {
  final String id;
  final String blocServiceId;
  final String partyName;
  final String loungeId;
  final String imageUrl;
  final int createdAt;
  final int partyDate;
  final int endTime;
  List<String> likers;
  int downloadCount;

//<editor-fold desc="Data Methods">
  PartyPhoto({
    required this.id,
    required this.blocServiceId,
    required this.partyName,
    required this.loungeId,
    required this.imageUrl,
    required this.createdAt,
    required this.partyDate,
    required this.endTime,
    required this.likers,
    required this.downloadCount,
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
          createdAt == other.createdAt &&
          partyDate == other.partyDate &&
          endTime == other.endTime &&
          likers == other.likers &&
          downloadCount == other.downloadCount);

  @override
  int get hashCode =>
      id.hashCode ^
      blocServiceId.hashCode ^
      partyName.hashCode ^
      loungeId.hashCode ^
      imageUrl.hashCode ^
      createdAt.hashCode ^
      partyDate.hashCode ^
      endTime.hashCode ^
      likers.hashCode ^
      downloadCount.hashCode;

  @override
  String toString() {
    return 'PartyPhoto{' +
        ' id: $id,' +
        ' blocServiceId: $blocServiceId,' +
        ' partyName: $partyName,' +
        ' loungeId: $loungeId,' +
        ' imageUrl: $imageUrl,' +
        ' createdAt: $createdAt,' +
        ' partyDate: $partyDate,' +
        ' endTime: $endTime,' +
        ' likers: $likers,' +
        ' downloadCount: $downloadCount,' +
        '}';
  }

  PartyPhoto copyWith({
    String? id,
    String? blocServiceId,
    String? partyName,
    String? loungeId,
    String? imageUrl,
    int? createdAt,
    int? partyDate,
    int? endTime,
    List<String>? likers,
    int? downloadCount,
  }) {
    return PartyPhoto(
      id: id ?? this.id,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      partyName: partyName ?? this.partyName,
      loungeId: loungeId ?? this.loungeId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      partyDate: partyDate ?? this.partyDate,
      endTime: endTime ?? this.endTime,
      likers: likers ?? this.likers,
      downloadCount: downloadCount ?? this.downloadCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'blocServiceId': this.blocServiceId,
      'partyName': this.partyName,
      'loungeId': this.loungeId,
      'imageUrl': this.imageUrl,
      'createdAt': this.createdAt,
      'partyDate': this.partyDate,
      'endTime': this.endTime,
      'likers': this.likers,
      'downloadCount': this.downloadCount,
    };
  }

  factory PartyPhoto.fromMap(Map<String, dynamic> map) {
    return PartyPhoto(
      id: map['id'] as String,
      blocServiceId: map['blocServiceId'] as String,
      partyName: map['partyName'] as String,
      loungeId: map['loungeId'] as String,
      imageUrl: map['imageUrl'] as String,
      createdAt: map['createdAt'] as int,
      partyDate: map['partyDate'] as int,
      endTime: map['endTime'] as int,
      likers: map['likers'] as List<String>,
      downloadCount: map['downloadCount'] as int,
    );
  }

//</editor-fold>
}