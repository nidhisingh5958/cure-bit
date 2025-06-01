import 'package:flutter/material.dart';
import 'package:CureBit/features/patient/chat/entities/message.dart';

class RequestBubble extends StatefulWidget {
  final Message message;

  const RequestBubble({super.key, required this.message});

  @override
  State<RequestBubble> createState() => _RequestBubbleState();
}

class _RequestBubbleState extends State<RequestBubble> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          widget.message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.message.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.message.imageUrl != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.message.imageUrl!,
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
                  if (widget.message.text != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.message.text!,
                      style: TextStyle(
                          color: widget.message.textColor, fontSize: 16),
                    ),
                  ],
                ],
              )
            : Text(
                widget.message.text!,
                style: TextStyle(color: widget.message.textColor, fontSize: 16),
              ),
      ),
    );
  }
}
