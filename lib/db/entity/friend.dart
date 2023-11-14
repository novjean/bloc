class Friend {
  final String id;
  final String userId;
  final String friendUserId;
  final bool isFollowing;
  final int friendshipDate;

//<editor-fold desc="Data Methods">
  const Friend({
    required this.id,
    required this.userId,
    required this.friendUserId,
    required this.isFollowing,
    required this.friendshipDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Friend &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          friendUserId == other.friendUserId &&
          isFollowing == other.isFollowing &&
          friendshipDate == other.friendshipDate);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      friendUserId.hashCode ^
      isFollowing.hashCode ^
      friendshipDate.hashCode;

  @override
  String toString() {
    return 'Friend{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' friendUserId: $friendUserId,' +
        ' isFollowing: $isFollowing,' +
        ' friendshipDate: $friendshipDate,' +
        '}';
  }

  Friend copyWith({
    String? id,
    String? userId,
    String? friendUserId,
    bool? isFollowing,
    int? friendshipDate,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendUserId: friendUserId ?? this.friendUserId,
      isFollowing: isFollowing ?? this.isFollowing,
      friendshipDate: friendshipDate ?? this.friendshipDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'friendUserId': this.friendUserId,
      'isFollowing': this.isFollowing,
      'friendshipDate': this.friendshipDate,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] as String,
      userId: map['userId'] as String,
      friendUserId: map['friendUserId'] as String,
      isFollowing: map['isFollowing'] as bool,
      friendshipDate: map['friendshipDate'] as int,
    );
  }

//</editor-fold>
}