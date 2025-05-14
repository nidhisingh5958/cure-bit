import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/doctor/chat/_request_screen.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_chat_data.dart';
import 'package:CuraDocs/features/doctor/chat/entities/_request_provider.dart';
import 'package:CuraDocs/features/doctor/home_screen/widgets/_side_menu.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/features/doctor/chat/data/chat_sample_data.dart';
import 'package:CuraDocs/features/doctor/chat/_chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DoctorChatListScreen extends StatefulWidget {
  const DoctorChatListScreen({super.key});

  @override
  State<DoctorChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<DoctorChatListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Chat',
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 24,
              color: black.withValues(alpha: .8),
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Requests'),
          ],
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: grey400, width: 2),
            ),
          ),
          splashBorderRadius: BorderRadius.circular(38),
          unselectedLabelColor: grey600,
          indicatorColor: grey600,
          dividerColor: Colors.transparent,
        ),
      ),
      drawer: const DoctorSideMenu(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => context.goNamed(RouteConstants.doctorChatBot),
      //   backgroundColor: black.withValues(alpha: .8),
      //   child: const Icon(Icons.chat_bubble_outline, color: white),
      // ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(chatData),
          _buildRequestList(),
        ],
      ),
    );
  }

  Widget _buildChatList(List<DocChatData> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final chat = data[index];
        return ChatListTile(
          chat: chat,
          onTap: () {
            if (!chat.isRequestAccepted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Please accept the request to start chatting')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorChatScreen(chat: chat),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestList() {
    return Consumer(
      builder: (context, ref, _) {
        final requests = ref.watch(requestProvider);
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final chat = requests[index];
            return RequestListTile(chat: chat, index: index);
          },
        );
      },
    );
  }
}

class ChatListTile extends StatelessWidget {
  final DocChatData chat;
  final VoidCallback? onTap;

  const ChatListTile({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorChatScreen(chat: chat),
              ),
            );
          },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade100,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: black,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.lastMessage,
          style: TextStyle(
            color: grey600,
            fontSize: 14,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: grey600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RequestListTile extends ConsumerWidget {
  final DocRequestData chat;
  final int index;

  const RequestListTile({super.key, required this.chat, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(requestProvider.notifier);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestScreen(chat: chat),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade100,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
          ),
        ],
      ),
      title: Text(
        chat.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: black,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.firstMessage,
          style: TextStyle(
            color: grey600,
            fontSize: 14,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
