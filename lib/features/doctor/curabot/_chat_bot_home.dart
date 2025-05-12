import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/features/doctor/curabot/widgets/_bot_search_bar.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final name = 'Sumit';

class ChatBotAssistantHome extends StatefulWidget {
  const ChatBotAssistantHome({super.key});

  @override
  State<ChatBotAssistantHome> createState() => _ChatBotAssistantHomeState();
}

class _ChatBotAssistantHomeState extends State<ChatBotAssistantHome> {
  final GlobalKey<DoctorBotSearchBarState> _searchBarKey =
      GlobalKey<DoctorBotSearchBarState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: "Cura Bot",
        onBackPressed: () {
          context.goNamed(RouteConstants.doctorHome);
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_rounded),
            onPressed: () {
              context.pushNamed(RouteConstants.doctorChatBotHistory);
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
                            "Hello, Dr. $name",
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
                    child: DoctorBotSearchBar(key: _searchBarKey),
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
