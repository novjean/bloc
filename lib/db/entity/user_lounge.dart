class UserLounge {
  final String id;
  final String userId;
  final String loungeId;
  final int lastAccessedTime;
  final bool isAccepted;

//<editor-fold desc="Data Methods">
  const UserLounge({
    required this.id,
    required this.userId,
    required this.loungeId,
    required this.lastAccessedTime,
    required this.isAccepted,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLounge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          loungeId == other.loungeId &&
          lastAccessedTime == other.lastAccessedTime &&
          isAccepted == other.isAccepted);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      loungeId.hashCode ^
      lastAccessedTime.hashCode ^
      isAccepted.hashCode;

  @override
  String toString() {
    return 'UserLounge{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' loungeId: $loungeId,' +
        ' lastAccessedTime: $lastAccessedTime,' +
        ' isAccepted: $isAccepted,' +
        '}';
  }

  UserLounge copyWith({
    String? id,
    String? userId,
    String? loungeId,
    int? lastAccessedTime,
    bool? isAccepted,
  }) {
    return UserLounge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loungeId: loungeId ?? this.loungeId,
      lastAccessedTime: lastAccessedTime ?? this.lastAccessedTime,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'loungeId': this.loungeId,
      'lastAccessedTime': this.lastAccessedTime,
      'isAccepted': this.isAccepted,
    };
  }

  factory UserLounge.fromMap(Map<String, dynamic> map) {
    return UserLounge(
      id: map['id'] as String,
      userId: map['userId'] as String,
      loungeId: map['loungeId'] as String,
      lastAccessedTime: map['lastAccessedTime'] as int,
      isAccepted: map['isAccepted'] as bool,
    );
  }

//</editor-fold>
}

