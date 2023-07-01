class PartyInterest{
  String id;
  String partyId;
  List<String> userIds;

//<editor-fold desc="Data Methods">
  PartyInterest({
    required this.id,
    required this.partyId,
    required this.userIds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyInterest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          partyId == other.partyId &&
          userIds == other.userIds);

  @override
  int get hashCode => id.hashCode ^ partyId.hashCode ^ userIds.hashCode;

  @override
  String toString() {
    return 'PartyInterest{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' userIds: $userIds,' +
        '}';
  }

  PartyInterest copyWith({
    String? id,
    String? partyId,
    List<String>? userIds,
  }) {
    return PartyInterest(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      userIds: userIds ?? this.userIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'partyId': this.partyId,
      'userIds': this.userIds,
    };
  }

  factory PartyInterest.fromMap(Map<String, dynamic> map) {
    return PartyInterest(
      id: map['id'] as String,
      partyId: map['partyId'] as String,
      userIds: map['userIds'] as List<String>,
    );
  }

//</editor-fold>
}