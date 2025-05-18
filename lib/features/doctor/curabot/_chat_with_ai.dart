import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:CuraDocs/features/doctor/curabot/entities/message_group.dart';
import 'package:CuraDocs/features/doctor/curabot/widgets/_bot_search_bar.dart';
import 'package:CuraDocs/features/doctor/curabot/widgets/_chat_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:CuraDocs/features/doctor/curabot/data/messages_bot.dart';
import 'package:CuraDocs/features/doctor/curabot/entities/message_bot.dart';

class DoctorBotScreen extends StatefulWidget {
  const DoctorBotScreen({super.key});

  @override
  State<DoctorBotScreen> createState() => _DoctorBotScreenState();
}

class _DoctorBotScreenState extends State<DoctorBotScreen> {
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
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppHeader(
        elevation: 1,
        backgroundColor: white,
        title: "Cura Bot",
        centerTitle: true,
        foregroundColor: black,
        onBackPressed: () => context.pop(),
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
            DoctorBotSearchBar(),
          ],
        ),
      ),
    );
  }
}

// class DoctorBotScreen extends StatefulWidget {
//   const DoctorBotScreen({super.key});

//   @override
//   State<DoctorBotScreen> createState() => _DoctorBotScreenState();
// }

// class _DoctorBotScreenState extends State<DoctorBotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         centerTitle: true,
//         title: Column(
//           children: [
//             const Text(
//               "Health Assistant",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 4),
//           ],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//           onPressed: () => context.pop(),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.more_horiz_rounded),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.separated(
//                 controller: _scrollController,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//                 itemBuilder: (context, index) {
//                   final message = messages[index];
//                   return Align(
//                     alignment: message.sender == MessageSender.bot
//                         ? Alignment.centerLeft
//                         : Alignment.centerRight,
//                     child: Container(
//                       constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width * 0.75,
//                       ),
//                       child: message.type == MessageType.text
//                           ? TextMessage(message: message)
//                           : MediaMessage(message: message),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) =>
//                     const SizedBox(height: 16),
//                 itemCount: messages.length,
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       Icons.add_circle_outline_rounded,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     onPressed: () {},
//                   ),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: "Type your health query...",
//                         hintStyle: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade500,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 12,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(24),
//                           borderSide: BorderSide.none,
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             Icons.send_rounded,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           onPressed: () {
//                             if (_controller.text.isNotEmpty) {
//                               setState(() {
//                                 messages.add(Message(
//                                   type: MessageType.text,
//                                   sender: MessageSender.user,
//                                   text: _controller.text,
//                                 ));
//                                 _scrollToBottom();
//                                 _controller.clear();
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                       style: const TextStyle(fontSize: 14),
//                       minLines: 1,
//                       maxLines: 4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
