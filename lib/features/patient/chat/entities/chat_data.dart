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
    required String name,
    required String specialization,
    required String avatarUrl,
    required String firstMessage,
    required String time,
  }) : super(
          name: name,
          specialization: specialization,
          avatarUrl: avatarUrl,
          lastMessage: firstMessage,
          time: time,
        );
}
