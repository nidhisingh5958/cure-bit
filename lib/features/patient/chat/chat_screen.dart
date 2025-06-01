import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/common/components/pop_up.dart';
import 'package:CureBit/features/patient/chat/widgets/build_message.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'data/chat_sample_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CureBit/features/patient/chat/entities/chat_data.dart';
import 'package:CureBit/features/patient/chat/entities/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatData chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSendButton = false;
  bool _isTyping = false; // Add typing indicator state

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleTextChange);
    // Simulate typing indicator for demo
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isTyping = true);
      Future.delayed(const Duration(seconds: 4), () {
        setState(() => _isTyping = false);
      });
    });
  }

  void _handleTextChange() {
    setState(() {
      _showSendButton = _messageController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      extendBody: false,
      body: Column(
        children: [
          _buildDateDivider(),
          Expanded(
            child: _buildMessageList(),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.chat.avatarUrl),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildDot(delay: 0),
                _buildDot(delay: 300),
                _buildDot(delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int delay}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: value),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  // AppBar widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Hero(
            tag: 'avatar-${widget.chat.name}',
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.chat.avatarUrl),
              backgroundColor: Colors.grey[200],
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.chat.specialization,
                  style: const TextStyle(
                    fontSize: 12,
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
          icon: const Icon(Icons.videocam_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

// getting the time span of the message
  String _getMessageTimeSpan(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Widget _buildMessageTimeStamp(String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showAvatar = !message.isMe &&
            (index == messages.length - 1 || messages[index + 1].isMe);
        final showTimeStamp =
            index == 0 || _shouldShowTimeStamp(messages[index - 1], message);

        return Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showTimeStamp)
              _buildMessageTimeStamp(_getMessageTimeSpan(
                  DateTime.now())), // Replace with actual message time
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: message.isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!message.isMe && showAvatar) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.chat.avatarUrl),
                  ),
                  const SizedBox(width: 8),
                ],
                if (!message.isMe && !showAvatar) const SizedBox(width: 40),
                Flexible(
                  child: MessageBubble(message: message),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowTimeStamp(Message previousMessage, Message currentMessage) {
    // In a real app, compare actual message timestamps
    // This is a placeholder implementation
    return false;
  }

  Widget _buildDateDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Today',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        12,
        8,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: PopUp.buildPopupMenu(
                    context,
                    // icon: Icon(Icons.attach_file),
                    onSelected: (value) {
                      if (value == 'book') {
                        // Handle book appointment action
                        context.goNamed(RouteConstants.bookAppointment);
                      } else if (value == 'doctorQR') {
                        // Handle help action
                        context.goNamed(RouteConstants.helpAndSupport);
                      }
                    },
                    optionsList: [
                      {'book': 'Schedule Appointment'},
                      {'attach': 'Attach'},
                      {'doctorQR': 'Doctor\'s QR'},
                    ],
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showSendButton
                ? IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // Implement send functionality
                      _messageController.clear();
                    },
                    color: Theme.of(context).primaryColor,
                  )
                : IconButton(
                    icon: const Icon(Icons.mic_outlined),
                    onPressed: () {},
                    color: Colors.grey[600],
                  ),
          ),
        ],
      ),
    );
  }
}

//  Row(
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color:
//                             widget.chat.isOnline ? Colors.green : Colors.grey,
//                         // online or not
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       widget.chat.isOnline ? 'Online' : 'Offline',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color:
//                             widget.chat.isOnline ? Colors.green : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
