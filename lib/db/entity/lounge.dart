class Lounge{
  String id;
  String name;
  String description;
  String type;
  String imageUrl;

  List<String> admins;
  List<String> members;

  String lastChat;
  int lastChatTime;

  int creationTime;
  bool isActive;

//<editor-fold desc="Data Methods">
  Lounge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.admins,
    required this.members,
    required this.lastChat,
    required this.lastChatTime,
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
          description == other.description &&
          type == other.type &&
          imageUrl == other.imageUrl &&
          admins == other.admins &&
          members == other.members &&
          lastChat == other.lastChat &&
          lastChatTime == other.lastChatTime &&
          creationTime == other.creationTime &&
          isActive == other.isActive);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      type.hashCode ^
      imageUrl.hashCode ^
      admins.hashCode ^
      members.hashCode ^
      lastChat.hashCode ^
      lastChatTime.hashCode ^
      creationTime.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'Lounge{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        ' type: $type,' +
        ' imageUrl: $imageUrl,' +
        ' admins: $admins,' +
        ' members: $members,' +
        ' lastChat: $lastChat,' +
        ' lastChatTime: $lastChatTime,' +
        ' creationTime: $creationTime,' +
        ' isActive: $isActive,' +
        '}';
  }

  Lounge copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? imageUrl,
    List<String>? admins,
    List<String>? members,
    String? lastChat,
    int? lastChatTime,
    int? creationTime,
    bool? isActive,
  }) {
    return Lounge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      admins: admins ?? this.admins,
      members: members ?? this.members,
      lastChat: lastChat ?? this.lastChat,
      lastChatTime: lastChatTime ?? this.lastChatTime,
      creationTime: creationTime ?? this.creationTime,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'description': this.description,
      'type': this.type,
      'imageUrl': this.imageUrl,
      'admins': this.admins,
      'members': this.members,
      'lastChat': this.lastChat,
      'lastChatTime': this.lastChatTime,
      'creationTime': this.creationTime,
      'isActive': this.isActive,
    };
  }

  factory Lounge.fromMap(Map<String, dynamic> map) {
    return Lounge(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      imageUrl: map['imageUrl'] as String,
      admins: map['admins'] as List<String>,
      members: map['members'] as List<String>,
      lastChat: map['lastChat'] as String,
      lastChatTime: map['lastChatTime'] as int,
      creationTime: map['creationTime'] as int,
      isActive: map['isActive'] as bool,
    );
  }

//</editor-fold>
}