class Lounge{
  String id;
  String name;
  String description;
  String rules;
  String type;
  String imageUrl;

  List<String> admins;
  List<String> members;

  String lastChat;
  int lastChatTime;

  int creationTime;
  bool isActive;
  bool isVip;

//<editor-fold desc="Data Methods">
  Lounge({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    required this.type,
    required this.imageUrl,
    required this.admins,
    required this.members,
    required this.lastChat,
    required this.lastChatTime,
    required this.creationTime,
    required this.isActive,
    required this.isVip,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lounge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          rules == other.rules &&
          type == other.type &&
          imageUrl == other.imageUrl &&
          admins == other.admins &&
          members == other.members &&
          lastChat == other.lastChat &&
          lastChatTime == other.lastChatTime &&
          creationTime == other.creationTime &&
          isActive == other.isActive &&
          isVip == other.isVip);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      rules.hashCode ^
      type.hashCode ^
      imageUrl.hashCode ^
      admins.hashCode ^
      members.hashCode ^
      lastChat.hashCode ^
      lastChatTime.hashCode ^
      creationTime.hashCode ^
      isActive.hashCode ^
      isVip.hashCode;

  @override
  String toString() {
    return 'Lounge{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        ' rules: $rules,' +
        ' type: $type,' +
        ' imageUrl: $imageUrl,' +
        ' admins: $admins,' +
        ' members: $members,' +
        ' lastChat: $lastChat,' +
        ' lastChatTime: $lastChatTime,' +
        ' creationTime: $creationTime,' +
        ' isActive: $isActive,' +
        ' isVip: $isVip,' +
        '}';
  }

  Lounge copyWith({
    String? id,
    String? name,
    String? description,
    String? rules,
    String? type,
    String? imageUrl,
    List<String>? admins,
    List<String>? members,
    String? lastChat,
    int? lastChatTime,
    int? creationTime,
    bool? isActive,
    bool? isVip,
  }) {
    return Lounge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      admins: admins ?? this.admins,
      members: members ?? this.members,
      lastChat: lastChat ?? this.lastChat,
      lastChatTime: lastChatTime ?? this.lastChatTime,
      creationTime: creationTime ?? this.creationTime,
      isActive: isActive ?? this.isActive,
      isVip: isVip ?? this.isVip,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'description': this.description,
      'rules': this.rules,
      'type': this.type,
      'imageUrl': this.imageUrl,
      'admins': this.admins,
      'members': this.members,
      'lastChat': this.lastChat,
      'lastChatTime': this.lastChatTime,
      'creationTime': this.creationTime,
      'isActive': this.isActive,
      'isVip': this.isVip,
    };
  }

  factory Lounge.fromMap(Map<String, dynamic> map) {
    return Lounge(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      rules: map['rules'] as String,
      type: map['type'] as String,
      imageUrl: map['imageUrl'] as String,
      admins: map['admins'] as List<String>,
      members: map['members'] as List<String>,
      lastChat: map['lastChat'] as String,
      lastChatTime: map['lastChatTime'] as int,
      creationTime: map['creationTime'] as int,
      isActive: map['isActive'] as bool,
      isVip: map['isVip'] as bool,
    );
  }

//</editor-fold>
}