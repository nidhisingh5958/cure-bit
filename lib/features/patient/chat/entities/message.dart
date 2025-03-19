import 'package:flutter/material.dart';

enum MessageSender { user, bot }

class Message {
  final String? text;
  final String? imageUrl;
  final MessageSender sender;

  // Add the following constructor to the Message class
  Message({
    this.text,
    this.imageUrl,
    required this.sender,
  });

  // Add the following getter to the Message class
  bool get isMe => sender == MessageSender.user;

  Color get backgroundColor => isMe ? Colors.blue.shade300 : Colors.grey[200]!;

  // text color
  Color get textColor => isMe ? Colors.white : Colors.black;
}
