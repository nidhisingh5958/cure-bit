import 'package:flutter/material.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_message.dart';

class MessageBubble extends StatelessWidget {
  final DocMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: message.imageUrl != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline),
                        );
                      },
                    ),
                  ),
                  if (message.text != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message.text!,
                      style: TextStyle(color: message.textColor, fontSize: 16),
                    ),
                  ],
                ],
              )
            : Text(
                message.text!,
                style: TextStyle(color: message.textColor, fontSize: 16),
              ),
      ),
    );
  }
}
