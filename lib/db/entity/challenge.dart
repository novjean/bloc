class Challenge {
  final String id;
  final int level;
  final String title;
  final String description;
  final int points;
  final int clickCount;

  final String dialogTitle;

  //todo: deprecated since 2.3.6
  final String dialogAcceptText;
  final String dialogAccept2Text;

//<editor-fold desc="Data Methods">
  const Challenge({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    required this.points,
    required this.clickCount,
    required this.dialogTitle,
    required this.dialogAcceptText,
    required this.dialogAccept2Text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Challenge &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          level == other.level &&
          title == other.title &&
          description == other.description &&
          points == other.points &&
          clickCount == other.clickCount &&
          dialogTitle == other.dialogTitle &&
          dialogAcceptText == other.dialogAcceptText &&
          dialogAccept2Text == other.dialogAccept2Text);

  @override
  int get hashCode =>
      id.hashCode ^
      level.hashCode ^
      title.hashCode ^
      description.hashCode ^
      points.hashCode ^
      clickCount.hashCode ^
      dialogTitle.hashCode ^
      dialogAcceptText.hashCode ^
      dialogAccept2Text.hashCode;

  @override
  String toString() {
    return 'Challenge{' +
        ' id: $id,' +
        ' level: $level,' +
        ' title: $title,' +
        ' description: $description,' +
        ' points: $points,' +
        ' clickCount: $clickCount,' +
        ' dialogTitle: $dialogTitle,' +
        ' dialogAcceptText: $dialogAcceptText,' +
        ' dialogAccept2Text: $dialogAccept2Text,' +
        '}';
  }

  Challenge copyWith({
    String? id,
    int? level,
    String? title,
    String? description,
    int? points,
    int? clickCount,
    String? dialogTitle,
    String? dialogAcceptText,
    String? dialogAccept2Text,
  }) {
    return Challenge(
      id: id ?? this.id,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      clickCount: clickCount ?? this.clickCount,
      dialogTitle: dialogTitle ?? this.dialogTitle,
      dialogAcceptText: dialogAcceptText ?? this.dialogAcceptText,
      dialogAccept2Text: dialogAccept2Text ?? this.dialogAccept2Text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'level': this.level,
      'title': this.title,
      'description': this.description,
      'points': this.points,
      'clickCount': this.clickCount,
      'dialogTitle': this.dialogTitle,
      'dialogAcceptText': this.dialogAcceptText,
      'dialogAccept2Text': this.dialogAccept2Text,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      level: map['level'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      points: map['points'] as int,
      clickCount: map['clickCount'] as int,
      dialogTitle: map['dialogTitle'] as String,
      dialogAcceptText: map['dialogAcceptText'] as String,
      dialogAccept2Text: map['dialogAccept2Text'] as String,
    );
  }

//</editor-fold>
}