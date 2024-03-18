class Job {
  String id;
  String title;
  String description;
  bool isActive;

  int postingDate;

//<editor-fold desc="Data Methods">


  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.postingDate,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Job &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              description == other.description &&
              isActive == other.isActive &&
              postingDate == other.postingDate
          );


  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      isActive.hashCode ^
      postingDate.hashCode;


  @override
  String toString() {
    return 'Job{' +
        ' id: $id,' +
        ' title: $title,' +
        ' description: $description,' +
        ' isActive: $isActive,' +
        ' postingDate: $postingDate,' +
        '}';
  }


  Job copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    int? postingDate,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      postingDate: postingDate ?? this.postingDate,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'description': this.description,
      'isActive': this.isActive,
      'postingDate': this.postingDate,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      isActive: map['isActive'] as bool,
      postingDate: map['postingDate'] as int,
    );
  }


//</editor-fold>
}