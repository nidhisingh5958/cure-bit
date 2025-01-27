import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:cure_bit/components/routes/route_constants.dart';
import 'package:cure_bit/screens/chatbot/data/messages_bot.dart';
import 'package:cure_bit/screens/chatbot/entities/message_bot.dart';
import 'package:cure_bit/screens/chatbot/widgets/media_message.dart';
import 'package:cure_bit/screens/chatbot/widgets/text_message.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "AI Health Assistant",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              "Online",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.sender == MessageSender.bot
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: message.type == MessageType.text
                          ? TextMessage(message: message)
                          : MediaMessage(message: message),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: messages.length,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your health query...",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
                      ),
                      style: const TextStyle(fontSize: 14),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
