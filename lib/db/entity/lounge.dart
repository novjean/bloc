class Lounge{
  String id;
  String name;
  String type;

  List<String> admins;
  List<String> members;

  int creationTime;
  bool isActive;

//<editor-fold desc="Data Methods">
  Lounge({
    required this.id,
    required this.name,
    required this.type,
    required this.admins,
    required this.members,
    required this.creationTime,
    required this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lounge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          admins == other.admins &&
          members == other.members &&
          creationTime == other.creationTime &&
          isActive == other.isActive);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      admins.hashCode ^
      members.hashCode ^
      creationTime.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'Lounge{' +
        ' id: $id,' +
        ' name: $name,' +
        ' type: $type,' +
        ' admins: $admins,' +
        ' members: $members,' +
        ' creationTime: $creationTime,' +
        ' isActive: $isActive,' +
        '}';
  }

  Lounge copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? admins,
    List<String>? members,
    int? creationTime,
    bool? isActive,
  }) {
    return Lounge(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      admins: admins ?? this.admins,
      members: members ?? this.members,
      creationTime: creationTime ?? this.creationTime,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
      'admins': this.admins,
      'members': this.members,
      'creationTime': this.creationTime,
      'isActive': this.isActive,
    };
  }

  factory Lounge.fromMap(Map<String, dynamic> map) {
    return Lounge(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      admins: map['admins'] as List<String>,
      members: map['members'] as List<String>,
      creationTime: map['creationTime'] as int,
      isActive: map['isActive'] as bool,
    );
  }

//</editor-fold>
}