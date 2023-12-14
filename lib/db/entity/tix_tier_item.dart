class TixTier {
  String id;
  String tixId;

  String partyTixTierId;
  String tixTierName;
  String tixTierDescription;
  double tixTierPrice;
  int tixTierCount;

  int guestsRemaining;

  double tixTierTotal;

//<editor-fold desc="Data Methods">
  TixTier({
    required this.id,
    required this.tixId,
    required this.partyTixTierId,
    required this.tixTierName,
    required this.tixTierDescription,
    required this.tixTierPrice,
    required this.tixTierCount,
    required this.guestsRemaining,
    required this.tixTierTotal,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TixTier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tixId == other.tixId &&
          partyTixTierId == other.partyTixTierId &&
          tixTierName == other.tixTierName &&
          tixTierDescription == other.tixTierDescription &&
          tixTierPrice == other.tixTierPrice &&
          tixTierCount == other.tixTierCount &&
          guestsRemaining == other.guestsRemaining &&
          tixTierTotal == other.tixTierTotal);

  @override
  int get hashCode =>
      id.hashCode ^
      tixId.hashCode ^
      partyTixTierId.hashCode ^
      tixTierName.hashCode ^
      tixTierDescription.hashCode ^
      tixTierPrice.hashCode ^
      tixTierCount.hashCode ^
      guestsRemaining.hashCode ^
      tixTierTotal.hashCode;

  @override
  String toString() {
    return 'TixTier{' +
        ' id: $id,' +
        ' tixId: $tixId,' +
        ' partyTixTierId: $partyTixTierId,' +
        ' tixTierName: $tixTierName,' +
        ' tixTierDescription: $tixTierDescription,' +
        ' tixTierPrice: $tixTierPrice,' +
        ' tixTierCount: $tixTierCount,' +
        ' guestsRemaining: $guestsRemaining,' +
        ' tixTierTotal: $tixTierTotal,' +
        '}';
  }

  TixTier copyWith({
    String? id,
    String? tixId,
    String? partyTixTierId,
    String? tixTierName,
    String? tixTierDescription,
    double? tixTierPrice,
    int? tixTierCount,
    int? guestsRemaining,
    double? tixTierTotal,
  }) {
    return TixTier(
      id: id ?? this.id,
      tixId: tixId ?? this.tixId,
      partyTixTierId: partyTixTierId ?? this.partyTixTierId,
      tixTierName: tixTierName ?? this.tixTierName,
      tixTierDescription: tixTierDescription ?? this.tixTierDescription,
      tixTierPrice: tixTierPrice ?? this.tixTierPrice,
      tixTierCount: tixTierCount ?? this.tixTierCount,
      guestsRemaining: guestsRemaining ?? this.guestsRemaining,
      tixTierTotal: tixTierTotal ?? this.tixTierTotal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'tixId': this.tixId,
      'partyTixTierId': this.partyTixTierId,
      'tixTierName': this.tixTierName,
      'tixTierDescription': this.tixTierDescription,
      'tixTierPrice': this.tixTierPrice,
      'tixTierCount': this.tixTierCount,
      'guestsRemaining': this.guestsRemaining,
      'tixTierTotal': this.tixTierTotal,
    };
  }

  factory TixTier.fromMap(Map<String, dynamic> map) {
    return TixTier(
      id: map['id'] as String,
      tixId: map['tixId'] as String,
      partyTixTierId: map['partyTixTierId'] as String,
      tixTierName: map['tixTierName'] as String,
      tixTierDescription: map['tixTierDescription'] as String,
      tixTierPrice: map['tixTierPrice'] as double,
      tixTierCount: map['tixTierCount'] as int,
      guestsRemaining: map['guestsRemaining'] as int,
      tixTierTotal: map['tixTierTotal'] as double,
    );
  }

//</editor-fold>
}