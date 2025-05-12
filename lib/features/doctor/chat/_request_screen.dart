import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_chat_data.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_request_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RequestScreen extends ConsumerStatefulWidget {
  final DocRequestData chat;
  const RequestScreen({super.key, required this.chat});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    // Implement send message logic
    if (_messageController.text.trim().isNotEmpty) {
      // TODO: Implement actual message sending logic
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(requestProvider.notifier);
    final currentChat = ref
        .watch(requestProvider)
        .firstWhere((chat) => chat.name == widget.chat.name);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (!currentChat.isRequestAccepted)
            _buildRequestBox(context, notifier),
          const SizedBox(height: 8),
          Expanded(child: _buildMessagePreview()),
          _buildInputBar(context, currentChat.isRequestAccepted),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      centerTitle: false,
      titleSpacing: 0,
      title: Row(
        children: [
          Hero(
            tag: 'avatar-${widget.chat.name}',
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.chat.avatarUrl),
              backgroundColor: grey200,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.info, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRequestBox(BuildContext context, RequestNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: grey400),
      ),
      child: Column(
        children: [
          Text(
            'Accept message request from ${widget.chat.name}?',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Delete'),
              ),
              ElevatedButton(
                onPressed: () {
                  notifier.acceptRequestFromUser(widget.chat.name);
                },
                child: const Text('Accept'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMessagePreview() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 4),
          child: Center(
              child: Text('Wednesday',
                  style: TextStyle(color: Colors.grey, fontSize: 14))),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                    'Doc should I continue my existing prescription or there will be a change ?'),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text('10:30 am',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInputBar(BuildContext context, bool isRequestAccepted) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 8,
            color: black.withAlpha(20),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.paperclip, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: isRequestAccepted,
              decoration: InputDecoration(
                hintText: isRequestAccepted
                    ? 'Type a message'
                    : 'Accept to start chatting',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          GestureDetector(
            onTap: isRequestAccepted && _messageController.text.isNotEmpty
                ? _sendMessage
                : null,
            child: Icon(
              Icons.send,
              color: isRequestAccepted && _messageController.text.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : grey400,
            ),
          ),
        ],
      ),
    );
  }
}
