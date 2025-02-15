import 'package:CuraDocs/components/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/screens/chat/data/chat_sample_data.dart';
import 'package:CuraDocs/screens/chat/chat_screen.dart';
import 'package:CuraDocs/screens/chat/entities/chat_data.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.goNamed(RouteConstants.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatData.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chatData[index];
          return ChatListTile(chat: chat);
        },
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final ChatData chat;

  const ChatListTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade100,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.lastMessage,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
