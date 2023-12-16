class SupportChat {
  String id;
  String userId;
  String userName;

  String message;
  String imageUrl;
  String type;
  int time;

  bool isResponse;

//<editor-fold desc="Data Methods">
  SupportChat({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.imageUrl,
    required this.type,
    required this.time,
    required this.isResponse,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportChat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          userName == other.userName &&
          message == other.message &&
          imageUrl == other.imageUrl &&
          type == other.type &&
          time == other.time &&
          isResponse == other.isResponse);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      message.hashCode ^
      imageUrl.hashCode ^
      type.hashCode ^
      time.hashCode ^
      isResponse.hashCode;

  @override
  String toString() {
    return 'SupportChat{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' userName: $userName,' +
        ' message: $message,' +
        ' imageUrl: $imageUrl,' +
        ' type: $type,' +
        ' time: $time,' +
        ' isResponse: $isResponse,' +
        '}';
  }

  SupportChat copyWith({
    String? id,
    String? userId,
    String? userName,
    String? message,
    String? imageUrl,
    String? type,
    int? time,
    bool? isResponse,
  }) {
    return SupportChat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      time: time ?? this.time,
      isResponse: isResponse ?? this.isResponse,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'userName': this.userName,
      'message': this.message,
      'imageUrl': this.imageUrl,
      'type': this.type,
      'time': this.time,
      'isResponse': this.isResponse,
    };
  }

  factory SupportChat.fromMap(Map<String, dynamic> map) {
    return SupportChat(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      message: map['message'] as String,
      imageUrl: map['imageUrl'] as String,
      type: map['type'] as String,
      time: map['time'] as int,
      isResponse: map['isResponse'] as bool,
    );
  }

//</editor-fold>
}