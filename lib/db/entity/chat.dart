class Chat{
  String id;
  String loungeId;
  String userId;
  String userName;
  String userImage;

  String message;
  String type;
  int time;

  int vote;
  List<String> upVoters;
  List<String> downVoters;

//<editor-fold desc="Data Methods">
  Chat({
    required this.id,
    required this.loungeId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.message,
    required this.type,
    required this.time,
    required this.vote,
    required this.upVoters,
    required this.downVoters,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          loungeId == other.loungeId &&
          userId == other.userId &&
          userName == other.userName &&
          userImage == other.userImage &&
          message == other.message &&
          type == other.type &&
          time == other.time &&
          vote == other.vote &&
          upVoters == other.upVoters &&
          downVoters == other.downVoters);

  @override
  int get hashCode =>
      id.hashCode ^
      loungeId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userImage.hashCode ^
      message.hashCode ^
      type.hashCode ^
      time.hashCode ^
      vote.hashCode ^
      upVoters.hashCode ^
      downVoters.hashCode;

  @override
  String toString() {
    return 'Chat{' +
        ' id: $id,' +
        ' loungeId: $loungeId,' +
        ' userId: $userId,' +
        ' userName: $userName,' +
        ' userImage: $userImage,' +
        ' message: $message,' +
        ' type: $type,' +
        ' time: $time,' +
        ' vote: $vote,' +
        ' upVoters: $upVoters,' +
        ' downVoters: $downVoters,' +
        '}';
  }

  Chat copyWith({
    String? id,
    String? loungeId,
    String? userId,
    String? userName,
    String? userImage,
    String? message,
    String? type,
    int? time,
    int? vote,
    List<String>? upVoters,
    List<String>? downVoters,
  }) {
    return Chat(
      id: id ?? this.id,
      loungeId: loungeId ?? this.loungeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      vote: vote ?? this.vote,
      upVoters: upVoters ?? this.upVoters,
      downVoters: downVoters ?? this.downVoters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'loungeId': this.loungeId,
      'userId': this.userId,
      'userName': this.userName,
      'userImage': this.userImage,
      'message': this.message,
      'type': this.type,
      'time': this.time,
      'vote': this.vote,
      'upVoters': this.upVoters,
      'downVoters': this.downVoters,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      loungeId: map['loungeId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userImage: map['userImage'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      time: map['time'] as int,
      vote: map['vote'] as int,
      upVoters: map['upVoters'] as List<String>,
      downVoters: map['downVoters'] as List<String>,
    );
  }

//</editor-fold>
}