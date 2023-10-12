class PartyTixTier {
  String id;
  String partyId;

  int tierLevel;
  String tierName;
  String tierDescription;
  double tierPrice;

  int soldCount;
  int totalTix;

  bool isSoldOut;

//<editor-fold desc="Data Methods">
  PartyTixTier({
    required this.id,
    required this.partyId,
    required this.tierLevel,
    required this.tierName,
    required this.tierDescription,
    required this.tierPrice,
    required this.soldCount,
    required this.totalTix,
    required this.isSoldOut,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyTixTier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          partyId == other.partyId &&
          tierLevel == other.tierLevel &&
          tierName == other.tierName &&
          tierDescription == other.tierDescription &&
          tierPrice == other.tierPrice &&
          soldCount == other.soldCount &&
          totalTix == other.totalTix &&
          isSoldOut == other.isSoldOut);

  @override
  int get hashCode =>
      id.hashCode ^
      partyId.hashCode ^
      tierLevel.hashCode ^
      tierName.hashCode ^
      tierDescription.hashCode ^
      tierPrice.hashCode ^
      soldCount.hashCode ^
      totalTix.hashCode ^
      isSoldOut.hashCode;

  @override
  String toString() {
    return 'PartyTixTier{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' tierLevel: $tierLevel,' +
        ' tierName: $tierName,' +
        ' tierDescription: $tierDescription,' +
        ' tierPrice: $tierPrice,' +
        ' soldCount: $soldCount,' +
        ' totalTix: $totalTix,' +
        ' isSoldOut: $isSoldOut,' +
        '}';
  }

  PartyTixTier copyWith({
    String? id,
    String? partyId,
    int? tierLevel,
    String? tierName,
    String? tierDescription,
    double? tierPrice,
    int? soldCount,
    int? totalTix,
    bool? isSoldOut,
  }) {
    return PartyTixTier(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      tierLevel: tierLevel ?? this.tierLevel,
      tierName: tierName ?? this.tierName,
      tierDescription: tierDescription ?? this.tierDescription,
      tierPrice: tierPrice ?? this.tierPrice,
      soldCount: soldCount ?? this.soldCount,
      totalTix: totalTix ?? this.totalTix,
      isSoldOut: isSoldOut ?? this.isSoldOut,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'partyId': this.partyId,
      'tierLevel': this.tierLevel,
      'tierName': this.tierName,
      'tierDescription': this.tierDescription,
      'tierPrice': this.tierPrice,
      'soldCount': this.soldCount,
      'totalTix': this.totalTix,
      'isSoldOut': this.isSoldOut,
    };
  }

  factory PartyTixTier.fromMap(Map<String, dynamic> map) {
    return PartyTixTier(
      id: map['id'] as String,
      partyId: map['partyId'] as String,
      tierLevel: map['tierLevel'] as int,
      tierName: map['tierName'] as String,
      tierDescription: map['tierDescription'] as String,
      tierPrice: map['tierPrice'] as double,
      soldCount: map['soldCount'] as int,
      totalTix: map['totalTix'] as int,
      isSoldOut: map['isSoldOut'] as bool,
    );
  }

//</editor-fold>
}