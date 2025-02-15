import 'package:flutter/material.dart';

enum MessageSender { user, bot }

class Message {
  final String? text;
  final String? imageUrl;
  final MessageSender sender;

  Message({
    this.text,
    this.imageUrl,
    required this.sender,
  });

  bool get isMe => sender == MessageSender.user;

  Color get backgroundColor => isMe ? Colors.blue.shade300 : Colors.grey[200]!;

  Color get textColor => isMe ? Colors.white : Colors.black;
}
