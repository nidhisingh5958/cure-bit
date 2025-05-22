class ConnectionRequestModel {
  final String requestSentTo;
  final String requestSentFrom;
  final String timestamp;
  final String connectionType;

  ConnectionRequestModel({
    required this.requestSentTo,
    required this.requestSentFrom,
    required this.timestamp,
    required this.connectionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'request_sent_to': requestSentTo,
      'request_sent_from': requestSentFrom,
      'timestamp': timestamp,
      'connection_type': connectionType,
    };
  }

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestModel(
      requestSentTo: json['request_sent_to'],
      requestSentFrom: json['request_sent_from'],
      timestamp: json['timestamp'],
      connectionType: json['connection_type'],
    );
  }
}

class ConnectionResponseModel {
  final String message;
  final int statusCode;

  ConnectionResponseModel({
    required this.message,
    required this.statusCode,
  });

  factory ConnectionResponseModel.fromJson(Map<String, dynamic> json) {
    return ConnectionResponseModel(
      message: json['message'],
      statusCode: json['status_code'],
    );
  }
}
