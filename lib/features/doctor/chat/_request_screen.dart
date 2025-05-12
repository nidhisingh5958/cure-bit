import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestScreen extends ConsumerWidget {
  final dynamic chat;
  const RequestScreen({super.key, this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(requestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        backgroundColor: white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final chat = requests[index];
          final notifier = ref.read(requestProvider.notifier);

          return ListTile(
            onTap: () {
              if (!chat.isRequestAccepted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please accept the request to start chatting'),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestScreen(
                      chat: chat,
                    ),
                  ),
                );
              }
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
            title: Text(
              chat.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: black,
                  ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                chat.firstMessage,
                style: TextStyle(
                  color: grey600,
                  fontSize: 14,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: chat.isRequestAccepted
                ? const Text(
                    'Accepted',
                    style: TextStyle(color: Colors.green),
                  )
                : ElevatedButton(
                    onPressed: () {
                      notifier.acceptRequest(index);
                    },
                    child: const Text('Accept'),
                  ),
          );
        },
      ),
    );
  }
}
