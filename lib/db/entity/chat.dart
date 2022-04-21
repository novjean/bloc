class Chat{
  String userId;
  String userImage;
  String userName;
  String text;

  Chat({
    required this.userId,
    required this.userImage,
    required this.userName,
    required this.text,
    // required this.isOccupied,
  });

  static Chat fromJson(Map<String, dynamic> json) => Chat(
    userId: json['userId'],
    userImage: json['userImage'],
    userName: json['username'],
    text: json['text'],
    // isOccupied: json['isOccupied'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userImage': userImage,
    'username': userName,
    'text': text,
    // 'isOccupied': isOccupied,
  };

}