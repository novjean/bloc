class JobApplicant {
  String id;
  String jobId;

  String name;
  String phoneNumber;
  String resumeUrl;
  int creationDate;

//<editor-fold desc="Data Methods">
  JobApplicant({
    required this.id,
    required this.jobId,
    required this.name,
    required this.phoneNumber,
    required this.resumeUrl,
    required this.creationDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobApplicant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          jobId == other.jobId &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          resumeUrl == other.resumeUrl &&
          creationDate == other.creationDate);

  @override
  int get hashCode =>
      id.hashCode ^
      jobId.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      resumeUrl.hashCode ^
      creationDate.hashCode;

  @override
  String toString() {
    return 'JobApplicant{' +
        ' id: $id,' +
        ' jobId: $jobId,' +
        ' name: $name,' +
        ' phoneNumber: $phoneNumber,' +
        ' resumeUrl: $resumeUrl,' +
        ' creationDate: $creationDate,' +
        '}';
  }

  JobApplicant copyWith({
    String? id,
    String? jobId,
    String? name,
    String? phoneNumber,
    String? resumeUrl,
    int? creationDate,
  }) {
    return JobApplicant(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'jobId': this.jobId,
      'name': this.name,
      'phoneNumber': this.phoneNumber,
      'resumeUrl': this.resumeUrl,
      'creationDate': this.creationDate,
    };
  }

  factory JobApplicant.fromMap(Map<String, dynamic> map) {
    return JobApplicant(
      id: map['id'] as String,
      jobId: map['jobId'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      resumeUrl: map['resumeUrl'] as String,
      creationDate: map['creationDate'] as int,
    );
  }

//</editor-fold>
}