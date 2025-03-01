import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatBotHome extends StatelessWidget {
  const ChatBotHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Health Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How can I help you today?",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose an option below to get started",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    OptionCard(
                      text: "Ask your health queries",
                      icon: Icons.edit_note_rounded,
                      description:
                          "Get instant answers to your health questions",
                    ),
                    OptionCard(
                      text: "Analyze medical reports",
                      icon: Icons.document_scanner_rounded,
                      description: "Upload and understand your medical reports",
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Conversations",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "See all",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _historyItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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
    required this.description,
    super.key,
  });

  final String text;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600
          ? 260
          : (MediaQuery.of(context).size.width - 64) / 2,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => context.pushNamed(RouteConstants.chatBotScreen),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
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

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: ListTile(
        onTap: () {
          context.push(RouteConstants.chatBotScreen);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chat_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
      ),
    );
  }
}

const _historyItems = [
  "What is helirab-d used for?",
  "What are the symptoms of malaria?",
  "What is the dosage of paracetamol?",
  "Suggest a medicine for headache",
  "Suggest a medicine for stomachache",
  "Home remedies for treating cold",
  "What should I do to control my cholesterol?",
  "How can I treat headache?",
];
