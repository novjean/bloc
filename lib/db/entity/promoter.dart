class Promoter{
  final String id;
  final String name;
  final String type;
  final String ownerId;
  final List<String> helperIds;
  final int creationDate;

//<editor-fold desc="Data Methods">
  const Promoter({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.helperIds,
    required this.creationDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Promoter &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          ownerId == other.ownerId &&
          helperIds == other.helperIds &&
          creationDate == other.creationDate);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      ownerId.hashCode ^
      helperIds.hashCode ^
      creationDate.hashCode;

  @override
  String toString() {
    return 'Promoter{' +
        ' id: $id,' +
        ' name: $name,' +
        ' type: $type,' +
        ' ownerId: $ownerId,' +
        ' helperIds: $helperIds,' +
        ' creationDate: $creationDate,' +
        '}';
  }

  Promoter copyWith({
    String? id,
    String? name,
    String? type,
    String? ownerId,
    List<String>? helperIds,
    int? creationDate,
  }) {
    return Promoter(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      helperIds: helperIds ?? this.helperIds,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'type': this.type,
      'ownerId': this.ownerId,
      'helperIds': this.helperIds,
      'creationDate': this.creationDate,
    };
  }

  factory Promoter.fromMap(Map<String, dynamic> map) {
    return Promoter(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      ownerId: map['ownerId'] as String,
      helperIds: map['helperIds'] as List<String>,
      creationDate: map['creationDate'] as int,
    );
  }

//</editor-fold>
}