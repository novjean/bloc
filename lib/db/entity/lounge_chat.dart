class LoungeChat{
  String id;
  String loungeId;
  String loungeName;
  String userId;
  String userName;
  String userImage;

  String message;
  String imageUrl;
  String type;
  int time;

  int vote;
  List<String> upVoters;
  List<String> downVoters;

  int views;

//<editor-fold desc="Data Methods">
  LoungeChat({
    required this.id,
    required this.loungeId,
    required this.loungeName,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.message,
    required this.imageUrl,
    required this.type,
    required this.time,
    required this.vote,
    required this.upVoters,
    required this.downVoters,
    required this.views,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoungeChat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          loungeId == other.loungeId &&
          loungeName == other.loungeName &&
          userId == other.userId &&
          userName == other.userName &&
          userImage == other.userImage &&
          message == other.message &&
          imageUrl == other.imageUrl &&
          type == other.type &&
          time == other.time &&
          vote == other.vote &&
          upVoters == other.upVoters &&
          downVoters == other.downVoters &&
          views == other.views);

  @override
  int get hashCode =>
      id.hashCode ^
      loungeId.hashCode ^
      loungeName.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userImage.hashCode ^
      message.hashCode ^
      imageUrl.hashCode ^
      type.hashCode ^
      time.hashCode ^
      vote.hashCode ^
      upVoters.hashCode ^
      downVoters.hashCode ^
      views.hashCode;

  @override
  String toString() {
    return 'LoungeChat{' +
        ' id: $id,' +
        ' loungeId: $loungeId,' +
        ' loungeName: $loungeName,' +
        ' userId: $userId,' +
        ' userName: $userName,' +
        ' userImage: $userImage,' +
        ' message: $message,' +
        ' imageUrl: $imageUrl,' +
        ' type: $type,' +
        ' time: $time,' +
        ' vote: $vote,' +
        ' upVoters: $upVoters,' +
        ' downVoters: $downVoters,' +
        ' views: $views,' +
        '}';
  }

  LoungeChat copyWith({
    String? id,
    String? loungeId,
    String? loungeName,
    String? userId,
    String? userName,
    String? userImage,
    String? message,
    String? imageUrl,
    String? type,
    int? time,
    int? vote,
    List<String>? upVoters,
    List<String>? downVoters,
    int? views,
  }) {
    return LoungeChat(
      id: id ?? this.id,
      loungeId: loungeId ?? this.loungeId,
      loungeName: loungeName ?? this.loungeName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      time: time ?? this.time,
      vote: vote ?? this.vote,
      upVoters: upVoters ?? this.upVoters,
      downVoters: downVoters ?? this.downVoters,
      views: views ?? this.views,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'loungeId': this.loungeId,
      'loungeName': this.loungeName,
      'userId': this.userId,
      'userName': this.userName,
      'userImage': this.userImage,
      'message': this.message,
      'imageUrl': this.imageUrl,
      'type': this.type,
      'time': this.time,
      'vote': this.vote,
      'upVoters': this.upVoters,
      'downVoters': this.downVoters,
      'views': this.views,
    };
  }

  factory LoungeChat.fromMap(Map<String, dynamic> map) {
    return LoungeChat(
      id: map['id'] as String,
      loungeId: map['loungeId'] as String,
      loungeName: map['loungeName'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userImage: map['userImage'] as String,
      message: map['message'] as String,
      imageUrl: map['imageUrl'] as String,
      type: map['type'] as String,
      time: map['time'] as int,
      vote: map['vote'] as int,
      upVoters: map['upVoters'] as List<String>,
      downVoters: map['downVoters'] as List<String>,
      views: map['views'] as int,
    );
  }

//</editor-fold>
}