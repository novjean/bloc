class Party {
  final String id;
  final String name;
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

//<editor-fold desc="Data Methods">

  const Party({
    required this.id,
    required this.name,
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
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
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
          isActive == other.isActive);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
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
      isActive.hashCode;

  @override
  String toString() {
    return 'Party{' +
        ' id: $id,' +
        ' name: $name,' +
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
        '}';
  }

  Party copyWith({
    String? id,
    String? name,
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
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
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
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id'] as String,
      name: map['name'] as String,
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
    );
  }

//</editor-fold>
}