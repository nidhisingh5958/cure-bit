import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorBotHistory extends StatelessWidget {
  const DoctorBotHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cura Bot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: const [
            // Today section
            HistorySection(
              title: 'Today',
              items: ["Can you summarise Vishal's timeline"],
            ),

            // Previous 30 days section
            HistorySection(
              title: 'Previous 30 days',
              items: [
                "Highlight the main points of Rashmi's...",
                "Analyze this prescription and give the...",
                "Message Laxmi that she can be hosp..."
              ],
            ),

            // Older section
            HistorySection(
              title: 'Older',
              items: ["summarise Gautum's prescription"],
            ),
          ],
        ),
      ),
    );
  }
}

class HistorySection extends StatelessWidget {
  final String title;
  final List<String> items;

  const HistorySection({
    required this.title,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        ...items.map((text) => HistoryItem(text: text)),
      ],
    );
  }
}

class HistoryItem extends StatelessWidget {
  final String text;

  const HistoryItem({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to chat bot screen with the selected query
        context.push(RouteConstants.chatBotScreen, extra: text);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.chat_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define a more complete version of history management
class ChatHistoryManager {
  static final ChatHistoryManager _instance = ChatHistoryManager._internal();

  factory ChatHistoryManager() {
    return _instance;
  }

  ChatHistoryManager._internal();

  // Get all history entries organized by date
  Map<String, List<String>> getOrganizedHistory() {
    return {
      'Today': [
        "Can you summarise Vishal's timeline",
      ],
      'Previous 30 days': [
        "Highlight the main points of Rashmi's report",
        "Analyze this prescription and give the dosage",
        "Message Laxmi that she can be hospitalized tomorrow",
      ],
      'Older': [
        "summarise Gautum's prescription",
        "What is helirab-d used for?",
        "What are the symptoms of malaria?",
        "What is the dosage of paracetamol?",
      ],
    };
  }

  // Add a new history entry
  void addHistoryEntry(String query) {
    // Implementation would add to the appropriate date section
    // and handle persistence with shared_preferences or other storage
  }
}

// A version that integrates with the history manager
class BotHistoryWithData extends StatefulWidget {
  const BotHistoryWithData({super.key});

  @override
  State<BotHistoryWithData> createState() => _BotHistoryWithDataState();
}

class _BotHistoryWithDataState extends State<BotHistoryWithData> {
  final ChatHistoryManager _historyManager = ChatHistoryManager();
  late Map<String, List<String>> _organizedHistory;

  @override
  void initState() {
    super.initState();
    _organizedHistory = _historyManager.getOrganizedHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cura Bot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: _organizedHistory.entries.map((entry) {
          return HistorySection(
            title: entry.key,
            items: entry.value,
          );
        }).toList(),
      ),
    );
  }
}
