import 'package:cure_bit/components/routes/route_constants.dart';
import 'package:cure_bit/screens/chat/data/chat_sample_data.dart';
import 'package:cure_bit/screens/chat/entities/chat_data.dart';
import 'package:cure_bit/screens/chat/widgets/build_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  final ChatData chat;

  const ChatScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.push(RouteConstants.chat);
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}

// message input
Widget _buildMessageInput() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.emoji_emotions_outlined),
          onPressed: () {},
          color: Colors.grey,
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Type something...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(Icons.attach_file),
          onPressed: () {},
          color: Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            // send message
          },
          color: Colors.grey.shade400,
        ),
      ],
    ),
  );
}
