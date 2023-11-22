class FriendNotification{
  final String id;
  final String title;
  final String message;
  final String imageUrl;
  final String topic;
  final int time;

//<editor-fold desc="Data Methods">
  const FriendNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.topic,
    required this.time,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          message == other.message &&
          imageUrl == other.imageUrl &&
          topic == other.topic &&
          time == other.time);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      message.hashCode ^
      imageUrl.hashCode ^
      topic.hashCode ^
      time.hashCode;

  @override
  String toString() {
    return 'FriendNotification{' +
        ' id: $id,' +
        ' title: $title,' +
        ' message: $message,' +
        ' imageUrl: $imageUrl,' +
        ' topic: $topic,' +
        ' time: $time,' +
        '}';
  }

  FriendNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? imageUrl,
    String? topic,
    int? time,
  }) {
    return FriendNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      topic: topic ?? this.topic,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'message': this.message,
      'imageUrl': this.imageUrl,
      'topic': this.topic,
      'time': this.time,
    };
  }

  factory FriendNotification.fromMap(Map<String, dynamic> map) {
    return FriendNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      imageUrl: map['imageUrl'] as String,
      topic: map['topic'] as String,
      time: map['time'] as int,
    );
  }

//</editor-fold>
}