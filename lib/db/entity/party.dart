class Party {
  final String id;
  final String name;
  final String eventName;
  final String description;
  final String blocServiceId;

  final String imageUrl;
  final String instagramUrl;
  final String ticketUrl;
  final String listenUrl;

  final int createdAt;
  final int startTime;
  final int endTime;

  final String ownerId;
  final bool isTBA;
  final bool isActive;

  final bool isGuestListActive;
  final int guestListCount;
  final bool isEmailRequired;
  final int guestListEndTime;

  final String guestListRules;
  final String clubRules;

//<editor-fold desc="Data Methods">
  const Party({
    required this.id,
    required this.name,
    required this.eventName,
    required this.description,
    required this.blocServiceId,
    required this.imageUrl,
    required this.instagramUrl,
    required this.ticketUrl,
    required this.listenUrl,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.ownerId,
    required this.isTBA,
    required this.isActive,
    required this.isGuestListActive,
    required this.guestListCount,
    required this.isEmailRequired,
    required this.guestListEndTime,
    required this.guestListRules,
    required this.clubRules,
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
          imageUrl == other.imageUrl &&
          instagramUrl == other.instagramUrl &&
          ticketUrl == other.ticketUrl &&
          listenUrl == other.listenUrl &&
          createdAt == other.createdAt &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          ownerId == other.ownerId &&
          isTBA == other.isTBA &&
          isActive == other.isActive &&
          isGuestListActive == other.isGuestListActive &&
          guestListCount == other.guestListCount &&
          isEmailRequired == other.isEmailRequired &&
          guestListEndTime == other.guestListEndTime &&
          guestListRules == other.guestListRules &&
          clubRules == other.clubRules);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      eventName.hashCode ^
      description.hashCode ^
      blocServiceId.hashCode ^
      imageUrl.hashCode ^
      instagramUrl.hashCode ^
      ticketUrl.hashCode ^
      listenUrl.hashCode ^
      createdAt.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      ownerId.hashCode ^
      isTBA.hashCode ^
      isActive.hashCode ^
      isGuestListActive.hashCode ^
      guestListCount.hashCode ^
      isEmailRequired.hashCode ^
      guestListEndTime.hashCode ^
      guestListRules.hashCode ^
      clubRules.hashCode;

  @override
  String toString() {
    return 'Party{' +
        ' id: $id,' +
        ' name: $name,' +
        ' eventName: $eventName,' +
        ' description: $description,' +
        ' blocServiceId: $blocServiceId,' +
        ' imageUrl: $imageUrl,' +
        ' instagramUrl: $instagramUrl,' +
        ' ticketUrl: $ticketUrl,' +
        ' listenUrl: $listenUrl,' +
        ' createdAt: $createdAt,' +
        ' startTime: $startTime,' +
        ' endTime: $endTime,' +
        ' ownerId: $ownerId,' +
        ' isTBA: $isTBA,' +
        ' isActive: $isActive,' +
        ' isGuestListActive: $isGuestListActive,' +
        ' guestListCount: $guestListCount,' +
        ' isEmailRequired: $isEmailRequired,' +
        ' guestListEndTime: $guestListEndTime,' +
        ' guestListRules: $guestListRules,' +
        ' clubRules: $clubRules,' +
        '}';
  }

  Party copyWith({
    String? id,
    String? name,
    String? eventName,
    String? description,
    String? blocServiceId,
    String? imageUrl,
    String? instagramUrl,
    String? ticketUrl,
    String? listenUrl,
    int? createdAt,
    int? startTime,
    int? endTime,
    String? ownerId,
    bool? isTBA,
    bool? isActive,
    bool? isGuestListActive,
    int? guestListCount,
    bool? isEmailRequired,
    int? guestListEndTime,
    String? guestListRules,
    String? clubRules,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      imageUrl: imageUrl ?? this.imageUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      listenUrl: listenUrl ?? this.listenUrl,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      ownerId: ownerId ?? this.ownerId,
      isTBA: isTBA ?? this.isTBA,
      isActive: isActive ?? this.isActive,
      isGuestListActive: isGuestListActive ?? this.isGuestListActive,
      guestListCount: guestListCount ?? this.guestListCount,
      isEmailRequired: isEmailRequired ?? this.isEmailRequired,
      guestListEndTime: guestListEndTime ?? this.guestListEndTime,
      guestListRules: guestListRules ?? this.guestListRules,
      clubRules: clubRules ?? this.clubRules,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'eventName': this.eventName,
      'description': this.description,
      'blocServiceId': this.blocServiceId,
      'imageUrl': this.imageUrl,
      'instagramUrl': this.instagramUrl,
      'ticketUrl': this.ticketUrl,
      'listenUrl': this.listenUrl,
      'createdAt': this.createdAt,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'ownerId': this.ownerId,
      'isTBA': this.isTBA,
      'isActive': this.isActive,
      'isGuestListActive': this.isGuestListActive,
      'guestListCount': this.guestListCount,
      'isEmailRequired': this.isEmailRequired,
      'guestListEndTime': this.guestListEndTime,
      'guestListRules': this.guestListRules,
      'clubRules': this.clubRules,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'] as String,
      name: map['name'] as String,
      eventName: map['eventName'] as String,
      description: map['description'] as String,
      blocServiceId: map['blocServiceId'] as String,
      imageUrl: map['imageUrl'] as String,
      instagramUrl: map['instagramUrl'] as String,
      ticketUrl: map['ticketUrl'] as String,
      listenUrl: map['listenUrl'] as String,
      createdAt: map['createdAt'] as int,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
      ownerId: map['ownerId'] as String,
      isTBA: map['isTBA'] as bool,
      isActive: map['isActive'] as bool,
      isGuestListActive: map['isGuestListActive'] as bool,
      guestListCount: map['guestListCount'] as int,
      isEmailRequired: map['isEmailRequired'] as bool,
      guestListEndTime: map['guestListEndTime'] as int,
      guestListRules: map['guestListRules'] as String,
      clubRules: map['clubRules'] as String,
    );
  }

//</editor-fold>
}