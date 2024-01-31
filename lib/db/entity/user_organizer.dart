class UserOrganizer {
  final String id;
  final String userId;
  final String organizerId;
  final int creationTime;

//<editor-fold desc="Data Methods">
  const UserOrganizer({
    required this.id,
    required this.userId,
    required this.organizerId,
    required this.creationTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserOrganizer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          organizerId == other.organizerId &&
          creationTime == other.creationTime);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      organizerId.hashCode ^
      creationTime.hashCode;

  @override
  String toString() {
    return 'UserOrganizer{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' organizerId: $organizerId,' +
        ' creationTime: $creationTime,' +
        '}';
  }

  UserOrganizer copyWith({
    String? id,
    String? userId,
    String? organizerId,
    int? creationTime,
  }) {
    return UserOrganizer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizerId: organizerId ?? this.organizerId,
      creationTime: creationTime ?? this.creationTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'organizerId': this.organizerId,
      'creationTime': this.creationTime,
    };
  }

  factory UserOrganizer.fromMap(Map<String, dynamic> map) {
    return UserOrganizer(
      id: map['id'] as String,
      userId: map['userId'] as String,
      organizerId: map['organizerId'] as String,
      creationTime: map['creationTime'] as int,
    );
  }

//</editor-fold>
}