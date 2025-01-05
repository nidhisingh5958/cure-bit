import 'package:cure_bit/screens/chatbot/entities/message_bot.dart';
import 'package:flutter/material.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: message.backgroundColor,
        borderRadius: message.borderRadius,
      ),
      child: Text(
        message.text!,
        style: TextStyle(
          color: message.TextColor,
        ),
      ),
    );
  }
}
