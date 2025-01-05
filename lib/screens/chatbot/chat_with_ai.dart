import 'package:cure_bit/components/routes/route_constants.dart';
import 'package:cure_bit/screens/chatbot/data/messages_bot.dart';
import 'package:cure_bit/screens/chatbot/entities/message_bot.dart';
import 'package:cure_bit/screens/chatbot/widgets/media_message.dart';
import 'package:cure_bit/screens/chatbot/widgets/text_message.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Chat with AI Bot")),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteConstants.chatBot);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          // ss
          children: [
            Expanded(
              child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Align(
                      alignment: message.sender == MessageSender.bot
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: message.type == MessageType.text
                          ? TextMessage(message: message)
                          : MediaMessage(message: message),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: messages.length),
            ),

            //  bottom search bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.attachment_outlined),
                    onPressed: () {
                      // uploading part
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    // send message button
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          messages.add(Message(
                            type: MessageType.text,
                            sender: MessageSender.user,
                            text: _controller.text,
                          ));
                          _scrollToBottom();
                          _controller.clear();
                        });
                      }
                    },
                  ),
                  isDense: false,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Type your query here",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
