class Challenge {
  final String id;
  final int level;
  final String title;
  final String description;
  final int points;
  final int clickCount;

//<editor-fold desc="Data Methods">
  const Challenge({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    required this.points,
    required this.clickCount,
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
          clickCount == other.clickCount);

  @override
  int get hashCode =>
      id.hashCode ^
      level.hashCode ^
      title.hashCode ^
      description.hashCode ^
      points.hashCode ^
      clickCount.hashCode;

  @override
  String toString() {
    return 'Challenge{' +
        ' id: $id,' +
        ' level: $level,' +
        ' title: $title,' +
        ' description: $description,' +
        ' points: $points,' +
        ' clickCount: $clickCount,' +
        '}';
  }

  Challenge copyWith({
    String? id,
    int? level,
    String? title,
    String? description,
    int? points,
    int? clickCount,
  }) {
    return Challenge(
      id: id ?? this.id,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      clickCount: clickCount ?? this.clickCount,
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
    );
  }

//</editor-fold>
}