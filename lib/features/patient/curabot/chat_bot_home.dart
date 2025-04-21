import 'package:CuraDocs/features/patient/curabot/widgets/bot_search_bar.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatBotHome extends StatefulWidget {
  const ChatBotHome({super.key});

  @override
  State<ChatBotHome> createState() => _ChatBotHomeState();
}

class _ChatBotHomeState extends State<ChatBotHome> {
  final GlobalKey<BotSearchBarState> _searchBarKey =
      GlobalKey<BotSearchBarState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cura Bot"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            context.goNamed(RouteConstants.home);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_rounded),
            onPressed: () {
              context.pushNamed(RouteConstants.chatBotHistory);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              Column(
                children: [
                  // Expanded area for greeting content
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hello, Yuvraj",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "How can I help you today?",
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search bar at the bottom with padding
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: BotSearchBar(key: _searchBarKey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
