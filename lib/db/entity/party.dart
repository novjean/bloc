class Party {
  final String id;
  final String name;
  final String eventName;
  final String description;
  final String blocServiceId;
  final String type;
  final String chapter;

  final List<String> imageUrls;
  final String imageUrl;
  final String storyImageUrl;
  final String instagramUrl;
  final String ticketUrl;
  final String listenUrl;

  final int createdAt;
  final int startTime;
  final int endTime;

  final String ownerId;
  final bool isTBA;
  final bool isActive;
  final bool isBigAct;

  final bool isGuestListActive;
  final int guestListCount;
  final bool isEmailRequired;
  final int guestListEndTime;
  final String guestListRules;
  final String clubRules;

  final bool isChallengeActive;
  final int overrideChallengeNum;
  final String genre;

  final bool isTicketed;
  int ticketsSoldCount;
  double ticketsSalesTotal;

  List<String> artistIds;

  String loungeId;

//<editor-fold desc="Data Methods">
  Party({
    required this.id,
    required this.name,
    required this.eventName,
    required this.description,
    required this.blocServiceId,
    required this.type,
    required this.chapter,
    required this.imageUrls,
    required this.imageUrl,
    required this.storyImageUrl,
    required this.instagramUrl,
    required this.ticketUrl,
    required this.listenUrl,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.ownerId,
    required this.isTBA,
    required this.isActive,
    required this.isBigAct,
    required this.isGuestListActive,
    required this.guestListCount,
    required this.isEmailRequired,
    required this.guestListEndTime,
    required this.guestListRules,
    required this.clubRules,
    required this.isChallengeActive,
    required this.overrideChallengeNum,
    required this.genre,
    required this.isTicketed,
    required this.ticketsSoldCount,
    required this.ticketsSalesTotal,
    required this.artistIds,
    required this.loungeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          eventName == other.eventName &&
          description == other.description &&
          blocServiceId == other.blocServiceId &&
          type == other.type &&
          chapter == other.chapter &&
          imageUrls == other.imageUrls &&
          imageUrl == other.imageUrl &&
          storyImageUrl == other.storyImageUrl &&
          instagramUrl == other.instagramUrl &&
          ticketUrl == other.ticketUrl &&
          listenUrl == other.listenUrl &&
          createdAt == other.createdAt &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          ownerId == other.ownerId &&
          isTBA == other.isTBA &&
          isActive == other.isActive &&
          isBigAct == other.isBigAct &&
          isGuestListActive == other.isGuestListActive &&
          guestListCount == other.guestListCount &&
          isEmailRequired == other.isEmailRequired &&
          guestListEndTime == other.guestListEndTime &&
          guestListRules == other.guestListRules &&
          clubRules == other.clubRules &&
          isChallengeActive == other.isChallengeActive &&
          overrideChallengeNum == other.overrideChallengeNum &&
          genre == other.genre &&
          isTicketed == other.isTicketed &&
          ticketsSoldCount == other.ticketsSoldCount &&
          ticketsSalesTotal == other.ticketsSalesTotal &&
          artistIds == other.artistIds &&
          loungeId == other.loungeId);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      eventName.hashCode ^
      description.hashCode ^
      blocServiceId.hashCode ^
      type.hashCode ^
      chapter.hashCode ^
      imageUrls.hashCode ^
      imageUrl.hashCode ^
      storyImageUrl.hashCode ^
      instagramUrl.hashCode ^
      ticketUrl.hashCode ^
      listenUrl.hashCode ^
      createdAt.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      ownerId.hashCode ^
      isTBA.hashCode ^
      isActive.hashCode ^
      isBigAct.hashCode ^
      isGuestListActive.hashCode ^
      guestListCount.hashCode ^
      isEmailRequired.hashCode ^
      guestListEndTime.hashCode ^
      guestListRules.hashCode ^
      clubRules.hashCode ^
      isChallengeActive.hashCode ^
      overrideChallengeNum.hashCode ^
      genre.hashCode ^
      isTicketed.hashCode ^
      ticketsSoldCount.hashCode ^
      ticketsSalesTotal.hashCode ^
      artistIds.hashCode ^
      loungeId.hashCode;

  @override
  String toString() {
    return 'Party{' +
        ' id: $id,' +
        ' name: $name,' +
        ' eventName: $eventName,' +
        ' description: $description,' +
        ' blocServiceId: $blocServiceId,' +
        ' type: $type,' +
        ' chapter: $chapter,' +
        ' imageUrls: $imageUrls,' +
        ' imageUrl: $imageUrl,' +
        ' storyImageUrl: $storyImageUrl,' +
        ' instagramUrl: $instagramUrl,' +
        ' ticketUrl: $ticketUrl,' +
        ' listenUrl: $listenUrl,' +
        ' createdAt: $createdAt,' +
        ' startTime: $startTime,' +
        ' endTime: $endTime,' +
        ' ownerId: $ownerId,' +
        ' isTBA: $isTBA,' +
        ' isActive: $isActive,' +
        ' isBigAct: $isBigAct,' +
        ' isGuestListActive: $isGuestListActive,' +
        ' guestListCount: $guestListCount,' +
        ' isEmailRequired: $isEmailRequired,' +
        ' guestListEndTime: $guestListEndTime,' +
        ' guestListRules: $guestListRules,' +
        ' clubRules: $clubRules,' +
        ' isChallengeActive: $isChallengeActive,' +
        ' overrideChallengeNum: $overrideChallengeNum,' +
        ' genre: $genre,' +
        ' isTicketed: $isTicketed,' +
        ' ticketsSoldCount: $ticketsSoldCount,' +
        ' ticketsSalesTotal: $ticketsSalesTotal,' +
        ' artistIds: $artistIds,' +
        ' loungeId: $loungeId,' +
        '}';
  }

  Party copyWith({
    String? id,
    String? name,
    String? eventName,
    String? description,
    String? blocServiceId,
    String? type,
    String? chapter,
    List<String>? imageUrls,
    String? imageUrl,
    String? storyImageUrl,
    String? instagramUrl,
    String? ticketUrl,
    String? listenUrl,
    int? createdAt,
    int? startTime,
    int? endTime,
    String? ownerId,
    bool? isTBA,
    bool? isActive,
    bool? isBigAct,
    bool? isGuestListActive,
    int? guestListCount,
    bool? isEmailRequired,
    int? guestListEndTime,
    String? guestListRules,
    String? clubRules,
    bool? isChallengeActive,
    int? overrideChallengeNum,
    String? genre,
    bool? isTicketed,
    int? ticketsSoldCount,
    double? ticketsSalesTotal,
    List<String>? artistIds,
    String? loungeId,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      type: type ?? this.type,
      chapter: chapter ?? this.chapter,
      imageUrls: imageUrls ?? this.imageUrls,
      imageUrl: imageUrl ?? this.imageUrl,
      storyImageUrl: storyImageUrl ?? this.storyImageUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      listenUrl: listenUrl ?? this.listenUrl,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      ownerId: ownerId ?? this.ownerId,
      isTBA: isTBA ?? this.isTBA,
      isActive: isActive ?? this.isActive,
      isBigAct: isBigAct ?? this.isBigAct,
      isGuestListActive: isGuestListActive ?? this.isGuestListActive,
      guestListCount: guestListCount ?? this.guestListCount,
      isEmailRequired: isEmailRequired ?? this.isEmailRequired,
      guestListEndTime: guestListEndTime ?? this.guestListEndTime,
      guestListRules: guestListRules ?? this.guestListRules,
      clubRules: clubRules ?? this.clubRules,
      isChallengeActive: isChallengeActive ?? this.isChallengeActive,
      overrideChallengeNum: overrideChallengeNum ?? this.overrideChallengeNum,
      genre: genre ?? this.genre,
      isTicketed: isTicketed ?? this.isTicketed,
      ticketsSoldCount: ticketsSoldCount ?? this.ticketsSoldCount,
      ticketsSalesTotal: ticketsSalesTotal ?? this.ticketsSalesTotal,
      artistIds: artistIds ?? this.artistIds,
      loungeId: loungeId ?? this.loungeId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'eventName': this.eventName,
      'description': this.description,
      'blocServiceId': this.blocServiceId,
      'type': this.type,
      'chapter': this.chapter,
      'imageUrls': this.imageUrls,
      'imageUrl': this.imageUrl,
      'storyImageUrl': this.storyImageUrl,
      'instagramUrl': this.instagramUrl,
      'ticketUrl': this.ticketUrl,
      'listenUrl': this.listenUrl,
      'createdAt': this.createdAt,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'ownerId': this.ownerId,
      'isTBA': this.isTBA,
      'isActive': this.isActive,
      'isBigAct': this.isBigAct,
      'isGuestListActive': this.isGuestListActive,
      'guestListCount': this.guestListCount,
      'isEmailRequired': this.isEmailRequired,
      'guestListEndTime': this.guestListEndTime,
      'guestListRules': this.guestListRules,
      'clubRules': this.clubRules,
      'isChallengeActive': this.isChallengeActive,
      'overrideChallengeNum': this.overrideChallengeNum,
      'genre': this.genre,
      'isTicketed': this.isTicketed,
      'ticketsSoldCount': this.ticketsSoldCount,
      'ticketsSalesTotal': this.ticketsSalesTotal,
      'artistIds': this.artistIds,
      'loungeId': this.loungeId,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'] as String,
      name: map['name'] as String,
      eventName: map['eventName'] as String,
      description: map['description'] as String,
      blocServiceId: map['blocServiceId'] as String,
      type: map['type'] as String,
      chapter: map['chapter'] as String,
      imageUrls: map['imageUrls'] as List<String>,
      imageUrl: map['imageUrl'] as String,
      storyImageUrl: map['storyImageUrl'] as String,
      instagramUrl: map['instagramUrl'] as String,
      ticketUrl: map['ticketUrl'] as String,
      listenUrl: map['listenUrl'] as String,
      createdAt: map['createdAt'] as int,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
      ownerId: map['ownerId'] as String,
      isTBA: map['isTBA'] as bool,
      isActive: map['isActive'] as bool,
      isBigAct: map['isBigAct'] as bool,
      isGuestListActive: map['isGuestListActive'] as bool,
      guestListCount: map['guestListCount'] as int,
      isEmailRequired: map['isEmailRequired'] as bool,
      guestListEndTime: map['guestListEndTime'] as int,
      guestListRules: map['guestListRules'] as String,
      clubRules: map['clubRules'] as String,
      isChallengeActive: map['isChallengeActive'] as bool,
      overrideChallengeNum: map['overrideChallengeNum'] as int,
      genre: map['genre'] as String,
      isTicketed: map['isTicketed'] as bool,
      ticketsSoldCount: map['ticketsSoldCount'] as int,
      ticketsSalesTotal: map['ticketsSalesTotal'] as double,
      artistIds: map['artistIds'] as List<String>,
      loungeId: map['loungeId'] as String,
    );
  }

//</editor-fold>
}