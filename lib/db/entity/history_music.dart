class HistoryMusic {
  String id;
  String userId;
  String genre;
  int count;

//<editor-fold desc="Data Methods">
  HistoryMusic({
    required this.id,
    required this.userId,
    required this.genre,
    required this.count,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryMusic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          genre == other.genre &&
          count == other.count);

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ genre.hashCode ^ count.hashCode;

  @override
  String toString() {
    return 'HistoryMusic{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' genre: $genre,' +
        ' count: $count,' +
        '}';
  }

  HistoryMusic copyWith({
    String? id,
    String? userId,
    String? genre,
    int? count,
  }) {
    return HistoryMusic(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      genre: genre ?? this.genre,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'genre': this.genre,
      'count': this.count,
    };
  }

  factory HistoryMusic.fromMap(Map<String, dynamic> map) {
    return HistoryMusic(
      id: map['id'] as String,
      userId: map['userId'] as String,
      genre: map['genre'] as String,
      count: map['count'] as int,
    );
  }

//</editor-fold>
}