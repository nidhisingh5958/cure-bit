import 'package:cure_bit/components/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatBotHome extends StatelessWidget {
  const ChatBotHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot"),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     // Navigator.pop(context);
        //   },
        // ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // options for choosing (text, image)
            Column(
              children: [
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    OptionCard(
                      text: "Ask your queries",
                      icon: Icons.edit,
                    ),
                    OptionCard(
                      text: "Upload and ask",
                      icon: Icons.image_outlined,
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      "History",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // History of chat tiles
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _historyItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return BotHistory(text: _historyItems[index]);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  const OptionCard({
    required this.text,
    required this.icon,
    super.key,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600
          ? 260
          : (MediaQuery.of(context).size.width - 56) / 2,
      height: 140,
      // child: Card.filled(
      //   clipBehavior: Clip.hardEdge,
      //   elevation: 2,
      //   color: Theme.of(context).colorScheme.secondaryContainer,
      //   child: InkWell(
      //     onTap: () {
      //       // context.go(RouteConstants.chatBotScreen);
      //     },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => context.pushNamed(
            RouteConstants.chatBotScreen,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BotHistory extends StatelessWidget {
  const BotHistory({
    required this.text,
    super.key,
  });
  // final redirect;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      child: ListTile(
        onTap: () {
          context.push(RouteConstants.chatBotScreen);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // side: BorderSide(width: 0.5, color: Colors.grey.shade100),
        ),
        title: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        leading:
            Icon(Icons.chat_outlined, color: Colors.blue.shade700, size: 22),
        trailing: Icon(Icons.arrow_forward_rounded,
            color: Colors.blue.shade700, size: 22),
      ),
    );
  }
}

const _historyItems = [
  "What is helirab-d used for?",
  "What are the symptoms of malaria?",
  "What is the dosage of paracetamol?",
  "Suggest a medicine for headache?",
  "Suggest a medicine for stomachache?",
  "Home remedies for treating cold?",
  "What should I do to control my cholesterol?",
  "How can I treat headache?",
];
