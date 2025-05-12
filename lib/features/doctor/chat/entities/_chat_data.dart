class DocChatData {
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final bool isRequestAccepted; // ADD THIS

  DocChatData({
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
    this.isRequestAccepted = true, // default true for existing chats
  });
}

class DocRequestData {
  final String name;
  final String avatarUrl;
  final String firstMessage;
  final String time;

  final bool isRequestAccepted;

  const DocRequestData({
    required this.name,
    required this.avatarUrl,
    required this.firstMessage,
    required this.time,
    this.isRequestAccepted = false,
  });

  DocRequestData copyWith({
    String? name,
    String? avatarUrl,
    String? firstMessage,
    String? time,
    bool? isRequestAccepted,
  }) {
    return DocRequestData(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      firstMessage: firstMessage ?? this.firstMessage,
      time: time ?? this.time,
      isRequestAccepted: isRequestAccepted ?? this.isRequestAccepted,
    );
  }
}
