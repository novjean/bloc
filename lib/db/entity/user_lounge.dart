class UserLounge {
  final String id;
  final String userId;
  final String userFcmToken;
  final String loungeId;
  final int lastAccessedTime;
  final bool isAccepted;
  final bool isBanned;

//<editor-fold desc="Data Methods">
  const UserLounge({
    required this.id,
    required this.userId,
    required this.userFcmToken,
    required this.loungeId,
    required this.lastAccessedTime,
    required this.isAccepted,
    required this.isBanned,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLounge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          userFcmToken == other.userFcmToken &&
          loungeId == other.loungeId &&
          lastAccessedTime == other.lastAccessedTime &&
          isAccepted == other.isAccepted &&
          isBanned == other.isBanned);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      userFcmToken.hashCode ^
      loungeId.hashCode ^
      lastAccessedTime.hashCode ^
      isAccepted.hashCode ^
      isBanned.hashCode;

  @override
  String toString() {
    return 'UserLounge{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' userFcmToken: $userFcmToken,' +
        ' loungeId: $loungeId,' +
        ' lastAccessedTime: $lastAccessedTime,' +
        ' isAccepted: $isAccepted,' +
        ' isBanned: $isBanned,' +
        '}';
  }

  UserLounge copyWith({
    String? id,
    String? userId,
    String? userFcmToken,
    String? loungeId,
    int? lastAccessedTime,
    bool? isAccepted,
    bool? isBanned,
  }) {
    return UserLounge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFcmToken: userFcmToken ?? this.userFcmToken,
      loungeId: loungeId ?? this.loungeId,
      lastAccessedTime: lastAccessedTime ?? this.lastAccessedTime,
      isAccepted: isAccepted ?? this.isAccepted,
      isBanned: isBanned ?? this.isBanned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'userFcmToken': this.userFcmToken,
      'loungeId': this.loungeId,
      'lastAccessedTime': this.lastAccessedTime,
      'isAccepted': this.isAccepted,
      'isBanned': this.isBanned,
    };
  }

  factory UserLounge.fromMap(Map<String, dynamic> map) {
    return UserLounge(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userFcmToken: map['userFcmToken'] as String,
      loungeId: map['loungeId'] as String,
      lastAccessedTime: map['lastAccessedTime'] as int,
      isAccepted: map['isAccepted'] as bool,
      isBanned: map['isBanned'] as bool,
    );
  }

//</editor-fold>
}

