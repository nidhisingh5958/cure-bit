class ChatData {
  final String name;
  final String specialization;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;

  ChatData({
    required this.name,
    required this.specialization,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
  });
}

class RequestData extends ChatData {
  RequestData({
    required super.name,
    required super.specialization,
    required super.avatarUrl,
    required String firstMessage,
    required super.time,
  }) : super(
          lastMessage: firstMessage,
        );
}
