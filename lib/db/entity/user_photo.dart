class UserPhoto {
  final String id;
  final String userId;
  final String partyPhotoId;
  final bool isConfirmed;
  final int tagTime;

//<editor-fold desc="Data Methods">
  const UserPhoto({
    required this.id,
    required this.userId,
    required this.partyPhotoId,
    required this.isConfirmed,
    required this.tagTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          partyPhotoId == other.partyPhotoId &&
          isConfirmed == other.isConfirmed &&
          tagTime == other.tagTime);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      partyPhotoId.hashCode ^
      isConfirmed.hashCode ^
      tagTime.hashCode;

  @override
  String toString() {
    return 'UserPhoto{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' partyPhotoId: $partyPhotoId,' +
        ' isConfirmed: $isConfirmed,' +
        ' tagTime: $tagTime,' +
        '}';
  }

  UserPhoto copyWith({
    String? id,
    String? userId,
    String? partyPhotoId,
    bool? isConfirmed,
    int? tagTime,
  }) {
    return UserPhoto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyPhotoId: partyPhotoId ?? this.partyPhotoId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      tagTime: tagTime ?? this.tagTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'partyPhotoId': this.partyPhotoId,
      'isConfirmed': this.isConfirmed,
      'tagTime': this.tagTime,
    };
  }

  factory UserPhoto.fromMap(Map<String, dynamic> map) {
    return UserPhoto(
      id: map['id'] as String,
      userId: map['userId'] as String,
      partyPhotoId: map['partyPhotoId'] as String,
      isConfirmed: map['isConfirmed'] as bool,
      tagTime: map['tagTime'] as int,
    );
  }

//</editor-fold>
}