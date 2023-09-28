class NotificationTest{
  final String id;
  final String title;
  final String body;
  final String imageUrl;

//<editor-fold desc="Data Methods">
  const NotificationTest({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationTest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          imageUrl == other.imageUrl);

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ body.hashCode ^ imageUrl.hashCode;

  @override
  String toString() {
    return 'NotificationTest{' +
        ' id: $id,' +
        ' title: $title,' +
        ' body: $body,' +
        ' imageUrl: $imageUrl,' +
        '}';
  }

  NotificationTest copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
  }) {
    return NotificationTest(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'body': this.body,
      'imageUrl': this.imageUrl,
    };
  }

  factory NotificationTest.fromMap(Map<String, dynamic> map) {
    return NotificationTest(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

//</editor-fold>
}