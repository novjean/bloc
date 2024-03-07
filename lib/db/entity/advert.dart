class Advert {
  String id;
  String title;
  String userId;

  String userName;
  String userPhone;
  String userEmail;

  List<String> imageUrls;
  String linkUrl;
  int clickCount;
  int views;

  bool isActive;
  bool isPaused;

  int createdAt;
  int startTime;
  int endTime;

  bool isSuccess;
  bool isCompleted;

  String merchantTransactionId;
  final String transactionId;
  String transactionResponseCode;
  String result;

  double igst;
  double subTotal;
  double bookingFee;
  double total;

//<editor-fold desc="Data Methods">
  Advert({
    required this.id,
    required this.title,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.imageUrls,
    required this.linkUrl,
    required this.clickCount,
    required this.views,
    required this.isActive,
    required this.isPaused,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.isSuccess,
    required this.isCompleted,
    required this.merchantTransactionId,
    required this.transactionId,
    required this.transactionResponseCode,
    required this.result,
    required this.igst,
    required this.subTotal,
    required this.bookingFee,
    required this.total,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Advert &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          userId == other.userId &&
          userName == other.userName &&
          userPhone == other.userPhone &&
          userEmail == other.userEmail &&
          imageUrls == other.imageUrls &&
          linkUrl == other.linkUrl &&
          clickCount == other.clickCount &&
          views == other.views &&
          isActive == other.isActive &&
          isPaused == other.isPaused &&
          createdAt == other.createdAt &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          isSuccess == other.isSuccess &&
          isCompleted == other.isCompleted &&
          merchantTransactionId == other.merchantTransactionId &&
          transactionId == other.transactionId &&
          transactionResponseCode == other.transactionResponseCode &&
          result == other.result &&
          igst == other.igst &&
          subTotal == other.subTotal &&
          bookingFee == other.bookingFee &&
          total == other.total);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userPhone.hashCode ^
      userEmail.hashCode ^
      imageUrls.hashCode ^
      linkUrl.hashCode ^
      clickCount.hashCode ^
      views.hashCode ^
      isActive.hashCode ^
      isPaused.hashCode ^
      createdAt.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      isSuccess.hashCode ^
      isCompleted.hashCode ^
      merchantTransactionId.hashCode ^
      transactionId.hashCode ^
      transactionResponseCode.hashCode ^
      result.hashCode ^
      igst.hashCode ^
      subTotal.hashCode ^
      bookingFee.hashCode ^
      total.hashCode;

  @override
  String toString() {
    return 'Advert{' +
        ' id: $id,' +
        ' title: $title,' +
        ' userId: $userId,' +
        ' userName: $userName,' +
        ' userPhone: $userPhone,' +
        ' userEmail: $userEmail,' +
        ' imageUrls: $imageUrls,' +
        ' linkUrl: $linkUrl,' +
        ' clickCount: $clickCount,' +
        ' views: $views,' +
        ' isActive: $isActive,' +
        ' isPaused: $isPaused,' +
        ' createdAt: $createdAt,' +
        ' startTime: $startTime,' +
        ' endTime: $endTime,' +
        ' isSuccess: $isSuccess,' +
        ' isCompleted: $isCompleted,' +
        ' merchantTransactionId: $merchantTransactionId,' +
        ' transactionId: $transactionId,' +
        ' transactionResponseCode: $transactionResponseCode,' +
        ' result: $result,' +
        ' igst: $igst,' +
        ' subTotal: $subTotal,' +
        ' bookingFee: $bookingFee,' +
        ' total: $total,' +
        '}';
  }

  Advert copyWith({
    String? id,
    String? title,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    List<String>? imageUrls,
    String? linkUrl,
    int? clickCount,
    int? views,
    bool? isActive,
    bool? isPaused,
    int? createdAt,
    int? startTime,
    int? endTime,
    bool? isSuccess,
    bool? isCompleted,
    String? merchantTransactionId,
    String? transactionId,
    String? transactionResponseCode,
    String? result,
    double? igst,
    double? subTotal,
    double? bookingFee,
    double? total,
  }) {
    return Advert(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrl: linkUrl ?? this.linkUrl,
      clickCount: clickCount ?? this.clickCount,
      views: views ?? this.views,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isSuccess: isSuccess ?? this.isSuccess,
      isCompleted: isCompleted ?? this.isCompleted,
      merchantTransactionId:
          merchantTransactionId ?? this.merchantTransactionId,
      transactionId: transactionId ?? this.transactionId,
      transactionResponseCode:
          transactionResponseCode ?? this.transactionResponseCode,
      result: result ?? this.result,
      igst: igst ?? this.igst,
      subTotal: subTotal ?? this.subTotal,
      bookingFee: bookingFee ?? this.bookingFee,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'userId': this.userId,
      'userName': this.userName,
      'userPhone': this.userPhone,
      'userEmail': this.userEmail,
      'imageUrls': this.imageUrls,
      'linkUrl': this.linkUrl,
      'clickCount': this.clickCount,
      'views': this.views,
      'isActive': this.isActive,
      'isPaused': this.isPaused,
      'createdAt': this.createdAt,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'isSuccess': this.isSuccess,
      'isCompleted': this.isCompleted,
      'merchantTransactionId': this.merchantTransactionId,
      'transactionId': this.transactionId,
      'transactionResponseCode': this.transactionResponseCode,
      'result': this.result,
      'igst': this.igst,
      'subTotal': this.subTotal,
      'bookingFee': this.bookingFee,
      'total': this.total,
    };
  }

  factory Advert.fromMap(Map<String, dynamic> map) {
    return Advert(
      id: map['id'] as String,
      title: map['title'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userPhone: map['userPhone'] as String,
      userEmail: map['userEmail'] as String,
      imageUrls: map['imageUrls'] as List<String>,
      linkUrl: map['linkUrl'] as String,
      clickCount: map['clickCount'] as int,
      views: map['views'] as int,
      isActive: map['isActive'] as bool,
      isPaused: map['isPaused'] as bool,
      createdAt: map['createdAt'] as int,
      startTime: map['startTime'] as int,
      endTime: map['endTime'] as int,
      isSuccess: map['isSuccess'] as bool,
      isCompleted: map['isCompleted'] as bool,
      merchantTransactionId: map['merchantTransactionId'] as String,
      transactionId: map['transactionId'] as String,
      transactionResponseCode: map['transactionResponseCode'] as String,
      result: map['result'] as String,
      igst: map['igst'] as double,
      subTotal: map['subTotal'] as double,
      bookingFee: map['bookingFee'] as double,
      total: map['total'] as double,
    );
  }

//</editor-fold>
}