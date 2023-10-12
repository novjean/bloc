class Tix {
  String id;
  String partyId;
  String userId;

  String userName;
  String userPhone;
  String userEmail;

  double total;
  String transactionId;
  int dateTime;
  bool isSuccess;
  bool isCompleted;

  List<String> tixTierItemIds;

//<editor-fold desc="Data Methods">
  Tix({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.total,
    required this.transactionId,
    required this.dateTime,
    required this.isSuccess,
    required this.isCompleted,
    required this.tixTierItemIds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tix &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          partyId == other.partyId &&
          userId == other.userId &&
          userName == other.userName &&
          userPhone == other.userPhone &&
          userEmail == other.userEmail &&
          total == other.total &&
          transactionId == other.transactionId &&
          dateTime == other.dateTime &&
          isSuccess == other.isSuccess &&
          isCompleted == other.isCompleted &&
          tixTierItemIds == other.tixTierItemIds);

  @override
  int get hashCode =>
      id.hashCode ^
      partyId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userPhone.hashCode ^
      userEmail.hashCode ^
      total.hashCode ^
      transactionId.hashCode ^
      dateTime.hashCode ^
      isSuccess.hashCode ^
      isCompleted.hashCode ^
      tixTierItemIds.hashCode;

  @override
  String toString() {
    return 'PartyTix{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' userId: $userId,' +
        ' userName: $userName,' +
        ' userPhone: $userPhone,' +
        ' userEmail: $userEmail,' +
        ' total: $total,' +
        ' transactionId: $transactionId,' +
        ' dateTime: $dateTime,' +
        ' isSuccess: $isSuccess,' +
        ' isCompleted: $isCompleted,' +
        ' tixTierItemIds: $tixTierItemIds,' +
        '}';
  }

  Tix copyWith({
    String? id,
    String? partyId,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    double? total,
    String? transactionId,
    int? dateTime,
    bool? isSuccess,
    bool? isCompleted,
    List<String>? tixTierItemIds,
  }) {
    return Tix(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      total: total ?? this.total,
      transactionId: transactionId ?? this.transactionId,
      dateTime: dateTime ?? this.dateTime,
      isSuccess: isSuccess ?? this.isSuccess,
      isCompleted: isCompleted ?? this.isCompleted,
      tixTierItemIds: tixTierItemIds ?? this.tixTierItemIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'partyId': this.partyId,
      'userId': this.userId,
      'userName': this.userName,
      'userPhone': this.userPhone,
      'userEmail': this.userEmail,
      'total': this.total,
      'transactionId': this.transactionId,
      'dateTime': this.dateTime,
      'isSuccess': this.isSuccess,
      'isCompleted': this.isCompleted,
      'tixTierItemIds': this.tixTierItemIds,
    };
  }

  factory Tix.fromMap(Map<String, dynamic> map) {
    return Tix(
      id: map['id'] as String,
      partyId: map['partyId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userPhone: map['userPhone'] as String,
      userEmail: map['userEmail'] as String,
      total: map['total'] as double,
      transactionId: map['transactionId'] as String,
      dateTime: map['dateTime'] as int,
      isSuccess: map['isSuccess'] as bool,
      isCompleted: map['isCompleted'] as bool,
      tixTierItemIds: map['tixTierItemIds'] as List<String>,
    );
  }

//</editor-fold>
}