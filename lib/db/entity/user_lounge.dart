class UserLounge {
  final String id;
  final String userId;
  final List<String> loungeIds;

//<editor-fold desc="Data Methods">
  const UserLounge({
    required this.id,
    required this.userId,
    required this.loungeIds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLounge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          loungeIds == other.loungeIds);

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ loungeIds.hashCode;

  @override
  String toString() {
    return 'UserLounge{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' loungeIds: $loungeIds,' +
        '}';
  }

  UserLounge copyWith({
    String? id,
    String? userId,
    List<String>? loungeIds,
  }) {
    return UserLounge(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loungeIds: loungeIds ?? this.loungeIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'loungeIds': this.loungeIds,
    };
  }

  factory UserLounge.fromMap(Map<String, dynamic> map) {
    return UserLounge(
      id: map['id'] as String,
      userId: map['userId'] as String,
      loungeIds: map['loungeIds'] as List<String>,
    );
  }

//</editor-fold>
}

