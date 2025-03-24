import 'package:CuraDocs/features/patient/curabot/entities/message_group.dart';
import 'package:CuraDocs/features/patient/curabot/widgets/bot_search_bar.dart';
import 'package:CuraDocs/features/patient/curabot/widgets/chat_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:CuraDocs/components/routes/route_constants.dart';
import 'package:CuraDocs/features/patient/curabot/data/messages_bot.dart';
import 'package:CuraDocs/features/patient/curabot/entities/message_bot.dart';
// import 'package:CuraDocs/screens/chatbot/widgets/media_message.dart';
// import 'package:CuraDocs/screens/chatbot/widgets/text_message.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageGroup> messageGroups = [];

  @override
  void initState() {
    super.initState();
    _groupMessages();
  }

  void _groupMessages() {
    List<MessageGroup> groups = [];
    List<Message> currentGroup = [];
    MessageSender? currentSender;

    for (var message in messages) {
      if (currentSender != message.sender && currentGroup.isNotEmpty) {
        groups.add(MessageGroup(
            messages: List.from(currentGroup), sender: currentSender!));
        currentGroup.clear();
      }
      currentGroup.add(message);
      currentSender = message.sender;
    }

    if (currentGroup.isNotEmpty) {
      groups.add(MessageGroup(
          messages: List.from(currentGroup), sender: currentSender!));
    }

    setState(() {
      messageGroups = groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Cura Bot",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemBuilder: (context, index) =>
                    ChatMessageWidget(group: messageGroups[index]),
                separatorBuilder: (context, index) => SizedBox(height: 24),
                itemCount: messageGroups.length,
              ),
            ),
            BotSearchBar(),
          ],
        ),
      ),
    );
  }
}



/* Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your health query...",
                        hintStyle:
                            TextStyle(fontSize: 14, color: Colors.grey[500]),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send_rounded, color: Colors.white),
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                setState(() {
                                  messages.add(Message(
                                    type: MessageType.text,
                                    sender: MessageSender.user,
                                    text: _controller.text,
                                  ));
                                  _groupMessages();
                                  _controller.clear();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),*/