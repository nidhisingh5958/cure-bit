class ChatData {
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;

  ChatData({
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
  });
}

class RequestData extends ChatData {
  RequestData({
    required super.name,
    required super.avatarUrl,
    required String firstMessage,
    required super.time,
  }) : super(
          lastMessage: firstMessage,
        );
}
