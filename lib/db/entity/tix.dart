class Tix {
  String id;
  String partyId;
  String userId;

  String userName;
  String userPhone;
  String userEmail;

  double igst;
  double subTotal;
  double bookingFee;
  double total;

  String merchantTransactionId;
  String transactionId;
  String transactionResponseCode;
  String result;

  int creationTime;
  bool isSuccess;
  bool isCompleted;
  bool isArrived;

  List<String> tixTierIds;

//<editor-fold desc="Data Methods">
  Tix({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.igst,
    required this.subTotal,
    required this.bookingFee,
    required this.total,
    required this.merchantTransactionId,
    required this.transactionId,
    required this.transactionResponseCode,
    required this.result,
    required this.creationTime,
    required this.isSuccess,
    required this.isCompleted,
    required this.isArrived,
    required this.tixTierIds,
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
          igst == other.igst &&
          subTotal == other.subTotal &&
          bookingFee == other.bookingFee &&
          total == other.total &&
          merchantTransactionId == other.merchantTransactionId &&
          transactionId == other.transactionId &&
          transactionResponseCode == other.transactionResponseCode &&
          result == other.result &&
          creationTime == other.creationTime &&
          isSuccess == other.isSuccess &&
          isCompleted == other.isCompleted &&
          isArrived == other.isArrived &&
          tixTierIds == other.tixTierIds);

  @override
  int get hashCode =>
      id.hashCode ^
      partyId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userPhone.hashCode ^
      userEmail.hashCode ^
      igst.hashCode ^
      subTotal.hashCode ^
      bookingFee.hashCode ^
      total.hashCode ^
      merchantTransactionId.hashCode ^
      transactionId.hashCode ^
      transactionResponseCode.hashCode ^
      result.hashCode ^
      creationTime.hashCode ^
      isSuccess.hashCode ^
      isCompleted.hashCode ^
      isArrived.hashCode ^
      tixTierIds.hashCode;

  @override
  String toString() {
    return 'Tix{' +
        ' id: $id,' +
        ' partyId: $partyId,' +
        ' userId: $userId,' +
        ' userName: $userName,' +
        ' userPhone: $userPhone,' +
        ' userEmail: $userEmail,' +
        ' igst: $igst,' +
        ' subTotal: $subTotal,' +
        ' bookingFee: $bookingFee,' +
        ' total: $total,' +
        ' merchantTransactionId: $merchantTransactionId,' +
        ' transactionId: $transactionId,' +
        ' transactionResponseCode: $transactionResponseCode,' +
        ' result: $result,' +
        ' creationTime: $creationTime,' +
        ' isSuccess: $isSuccess,' +
        ' isCompleted: $isCompleted,' +
        ' isArrived: $isArrived,' +
        ' tixTierIds: $tixTierIds,' +
        '}';
  }

  Tix copyWith({
    String? id,
    String? partyId,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    double? igst,
    double? subTotal,
    double? bookingFee,
    double? total,
    String? merchantTransactionId,
    String? transactionId,
    String? transactionResponseCode,
    String? result,
    int? creationTime,
    bool? isSuccess,
    bool? isCompleted,
    bool? isArrived,
    List<String>? tixTierIds,
  }) {
    return Tix(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      igst: igst ?? this.igst,
      subTotal: subTotal ?? this.subTotal,
      bookingFee: bookingFee ?? this.bookingFee,
      total: total ?? this.total,
      merchantTransactionId:
          merchantTransactionId ?? this.merchantTransactionId,
      transactionId: transactionId ?? this.transactionId,
      transactionResponseCode:
          transactionResponseCode ?? this.transactionResponseCode,
      result: result ?? this.result,
      creationTime: creationTime ?? this.creationTime,
      isSuccess: isSuccess ?? this.isSuccess,
      isCompleted: isCompleted ?? this.isCompleted,
      isArrived: isArrived ?? this.isArrived,
      tixTierIds: tixTierIds ?? this.tixTierIds,
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
      'igst': this.igst,
      'subTotal': this.subTotal,
      'bookingFee': this.bookingFee,
      'total': this.total,
      'merchantTransactionId': this.merchantTransactionId,
      'transactionId': this.transactionId,
      'transactionResponseCode': this.transactionResponseCode,
      'result': this.result,
      'creationTime': this.creationTime,
      'isSuccess': this.isSuccess,
      'isCompleted': this.isCompleted,
      'isArrived': this.isArrived,
      'tixTierIds': this.tixTierIds,
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
      igst: map['igst'] as double,
      subTotal: map['subTotal'] as double,
      bookingFee: map['bookingFee'] as double,
      total: map['total'] as double,
      merchantTransactionId: map['merchantTransactionId'] as String,
      transactionId: map['transactionId'] as String,
      transactionResponseCode: map['transactionResponseCode'] as String,
      result: map['result'] as String,
      creationTime: map['creationTime'] as int,
      isSuccess: map['isSuccess'] as bool,
      isCompleted: map['isCompleted'] as bool,
      isArrived: map['isArrived'] as bool,
      tixTierIds: map['tixTierIds'] as List<String>,
    );
  }

//</editor-fold>
}