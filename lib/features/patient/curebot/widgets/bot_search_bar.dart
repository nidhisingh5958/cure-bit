import 'package:CureBit/common/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:go_router/go_router.dart';

class BotSearchBar extends StatefulWidget {
  const BotSearchBar({super.key});

  @override
  State<BotSearchBar> createState() => BotSearchBarState();
}

class BotSearchBarState extends State<BotSearchBar>
    with SingleTickerProviderStateMixin {
  String query = '';
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  final FocusNode _focusNode = FocusNode();

  // Sample suggestions
  final List<String> _suggestions = [
    "What are the symptoms of COVID-19?",
    "How to lower blood pressure naturally?",
    "What causes headaches?",
    "How to manage stress and anxiety?",
    "What are the best vitamins for energy?"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _heightAnimation = Tween<double>(
      begin: 50.0, // Initial height
      end: 300.0, // Expanded height
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !isExpanded) {
      _expandSearchBar();
    }
  }

  void _expandSearchBar() {
    setState(() {
      isExpanded = true;
    });
    _animationController.forward();
  }

  void _collapseSearchBar() {
    setState(() {
      isExpanded = false;
    });
    _animationController.reverse();
    _focusNode.unfocus();
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  void _onSuggestionTap(String suggestion) {
    setState(() {
      query = suggestion;
    });
    // Navigate to chat screen with the query
    context.pushNamed(
      RouteConstants.chatBotScreen,
      extra: query,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: MediaQuery.of(context).size.width - 32,
          height: _heightAnimation.value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300),
            color: white,
            boxShadow: isExpanded
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input field
              TextField(
                focusNode: _focusNode,
                controller: TextEditingController(text: query),
                onChanged: onQueryChanged,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  prefixIcon: Icon(
                    Icons.add,
                    color: black,
                    size: 20,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isExpanded)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: black,
                            size: 20,
                          ),
                          onPressed: _collapseSearchBar,
                        )
                      else
                        Icon(
                          Icons.mic,
                          color: black,
                          size: 20,
                        ),
                    ],
                  ),
                  hintText: "Ask me anything",
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 14),
                minLines: 1,
                maxLines: 1,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.pushNamed(
                      RouteConstants.chatBotScreen,
                      extra: value,
                    );
                  }
                },
              ),

              // Suggestions
              if (isExpanded)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: _heightAnimation.value -
                      50, // Subtract input field height
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          _suggestions[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        leading: Icon(
                          Icons.history,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onTap: () => _onSuggestionTap(_suggestions[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
