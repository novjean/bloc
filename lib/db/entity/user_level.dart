class UserLevel {
  final String id;
  final String name;
  final int level;

//<editor-fold desc="Data Methods">

  const UserLevel({
    required this.id,
    required this.name,
    required this.level,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLevel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          level == other.level);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ level.hashCode;

  @override
  String toString() {
    return 'UserLevel{' +
        ' id: $id,' +
        ' name: $name,' +
        ' level: $level,' +
        '}';
  }

  UserLevel copyWith({
    String? id,
    String? name,
    int? level,
  }) {
    return UserLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'level': this.level,
    };
  }

  factory UserLevel.fromMap(Map<String, dynamic> map) {
    return UserLevel(
      id: map['id'] as String,
      name: map['name'] as String,
      level: map['level'] as int,
    );
  }

//</editor-fold>
}