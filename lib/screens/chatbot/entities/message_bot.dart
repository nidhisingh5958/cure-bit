import 'package:flutter/material.dart';

class Message {
  final MessageType type;
  final MessageSender sender;
  final String? text;
  final String? mediaUrl;

  const Message({
    required this.type,
    required this.sender,
    this.text,
    this.mediaUrl,
  });
}

extension MessageExtension on Message {
  Color get TextColor {
    switch (sender) {
      case MessageSender.bot:
        return Colors.white;
      case MessageSender.user:
        return Color(0xFF232729);
    }
  }

  Color get backgroundColor {
    switch (sender) {
      case MessageSender.bot:
        return Color(0xFF4d4d4d);
      case MessageSender.user:
        return Color(0xFFE7E7E7);
    }
  }

  BorderRadius get borderRadius {
    switch (sender) {
      case MessageSender.bot:
        return BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        );
      case MessageSender.user:
        return BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        );
    }
  }
}

enum MessageType { text, media }

enum MessageSender { bot, user }
