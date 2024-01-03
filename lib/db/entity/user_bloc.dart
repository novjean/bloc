class UserBloc {
  final String id;
  final String userId;
  final String blocServiceId;
  final int createdTime;

//<editor-fold desc="Data Methods">
  const UserBloc({
    required this.id,
    required this.userId,
    required this.blocServiceId,
    required this.createdTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBloc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          blocServiceId == other.blocServiceId &&
          createdTime == other.createdTime);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      blocServiceId.hashCode ^
      createdTime.hashCode;

  @override
  String toString() {
    return 'UserBloc{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' blocServiceId: $blocServiceId,' +
        ' createdTime: $createdTime,' +
        '}';
  }

  UserBloc copyWith({
    String? id,
    String? userId,
    String? blocServiceId,
    int? createdTime,
  }) {
    return UserBloc(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      blocServiceId: blocServiceId ?? this.blocServiceId,
      createdTime: createdTime ?? this.createdTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'blocServiceId': this.blocServiceId,
      'createdTime': this.createdTime,
    };
  }

  factory UserBloc.fromMap(Map<String, dynamic> map) {
    return UserBloc(
      id: map['id'] as String,
      userId: map['userId'] as String,
      blocServiceId: map['blocServiceId'] as String,
      createdTime: map['createdTime'] as int,
    );
  }

//</editor-fold>
}