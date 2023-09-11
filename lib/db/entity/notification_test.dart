class NotificationTest{
  final String id;
  final String text;

//<editor-fold desc="Data Methods">
  const NotificationTest({
    required this.id,
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is NotificationTest &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              text == other.text);

  @override
  int get hashCode => id.hashCode ^ text.hashCode;

  @override
  String toString() {
    return 'NotificationTest{' + ' id: $id,' + ' text: $text,' + '}';
  }

  NotificationTest copyWith({
    String? id,
    String? text,
  }) {
    return NotificationTest(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'text': this.text,
    };
  }

  factory NotificationTest.fromMap(Map<String, dynamic> map) {
    return NotificationTest(
      id: map['id'] as String,
      text: map['text'] as String,
    );
  }

//</editor-fold>
}