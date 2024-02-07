class PhonePeApiResponseData {
  String? merchantId;
  String? merchantTransactionId;
  InstrumentResponse? instrumentResponse;

  PhonePeApiResponseData({this.merchantId, this.merchantTransactionId, this.instrumentResponse});

  PhonePeApiResponseData.fromJson(Map<String, dynamic> json) {
    merchantId = json['merchantId'];
    merchantTransactionId = json['merchantTransactionId'];
    instrumentResponse = json['instrumentResponse'] != null
        ? InstrumentResponse.fromJson(json['instrumentResponse'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['merchantId'] = this.merchantId;
    data['merchantTransactionId'] = this.merchantTransactionId;
    if (this.instrumentResponse != null) {
      data['instrumentResponse'] = this.instrumentResponse!.toJson();
    }
    return data;
  }
}

class InstrumentResponse {
  String? type;
  RedirectInfo? redirectInfo;

  InstrumentResponse({this.type, this.redirectInfo});

  InstrumentResponse.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    redirectInfo = json['redirectInfo'] != null
        ? RedirectInfo.fromJson(json['redirectInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.redirectInfo != null) {
      data['redirectInfo'] = this.redirectInfo!.toJson();
    }
    return data;
  }
}

class RedirectInfo {
  String? url;
  String? method;

  RedirectInfo({this.url, this.method});

  RedirectInfo.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    method = json['method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['method'] = this.method;
    return data;
  }
}