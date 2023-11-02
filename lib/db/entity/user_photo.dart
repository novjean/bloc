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
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          partyPhotoId == other.partyPhotoId &&
          isConfirmed == other.isConfirmed);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      partyPhotoId.hashCode ^
      isConfirmed.hashCode;

  @override
  String toString() {
    return 'UserPhoto{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' partyPhotoId: $partyPhotoId,' +
        ' isConfirmed: $isConfirmed,' +
        '}';
  }

  UserPhoto copyWith({
    String? id,
    String? userId,
    String? partyPhotoId,
    bool? isConfirmed,
  }) {
    return UserPhoto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyPhotoId: partyPhotoId ?? this.partyPhotoId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'partyPhotoId': this.partyPhotoId,
      'isConfirmed': this.isConfirmed,
    };
  }

  factory UserPhoto.fromMap(Map<String, dynamic> map) {
    return UserPhoto(
      id: map['id'] as String,
      userId: map['userId'] as String,
      partyPhotoId: map['partyPhotoId'] as String,
      isConfirmed: map['isConfirmed'] as bool,
    );
  }

//</editor-fold>
}