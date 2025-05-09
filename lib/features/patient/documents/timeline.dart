import 'package:flutter/material.dart';

class TimelineEntry {
  final String title;
  final Widget content;

  TimelineEntry({required this.title, required this.content});
}

class Timeline extends StatefulWidget {
  final List<TimelineEntry> data;

  const Timeline({super.key, required this.data});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0;
  double _lineHeight = 0;
  final GlobalKey _timelineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureLineHeight();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _measureLineHeight() {
    final RenderBox? renderBox =
        _timelineKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _lineHeight = renderBox.size.height;
      });
    }
  }

  void _updateScrollProgress() {
    final RenderBox? renderBox =
        _timelineKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final containerHeight = renderBox.size.height;
      final viewportOffset = _scrollController.offset;
      final viewportHeight = _scrollController.position.viewportDimension;

      // Calculate progress based on viewport position
      final start = 0.0;
      final end = containerHeight - viewportHeight;

      if (end <= 0) {
        setState(() {
          _scrollProgress = 1.0;
        });
      } else {
        final normalizedOffset = (viewportOffset - start) / (end - start);
        setState(() {
          _scrollProgress = normalizedOffset.clamp(0.0, 1.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Changelog from my journey',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 768 ? 36.0 : 20.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Text(
                      "I've been working on Aceternity for the past 2 years. Here's a timeline of my journey.",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width > 768
                            ? 16.0
                            : 14.0,
                        color: isDarkMode
                            ? const Color(0xFFBBBBBB)
                            : const Color(0xFF505050),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              key: _timelineKey,
              constraints: const BoxConstraints(maxWidth: 1280),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Stack(
                children: [
                  // Vertical timeline line
                  Positioned(
                    left: MediaQuery.of(context).size.width > 768 ? 38.0 : 20.0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            isDarkMode
                                ? const Color(0xFF404040)
                                : const Color(0xFFE0E0E0),
                            isDarkMode
                                ? const Color(0xFF404040)
                                : const Color(0xFFE0E0E0),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.1, 0.9, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Animated progress line
                  Positioned(
                    left: MediaQuery.of(context).size.width > 768 ? 38.0 : 20.0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 2,
                        height: _lineHeight * _scrollProgress,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.purple,
                              Colors.blue,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.1, 1.0],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                        ),
                      ),
                    ),
                  ),

                  // Timeline entries
                  Column(
                    children: widget.data
                        .map((item) => _buildTimelineItem(item, isDarkMode))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEntry item, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.width > 768 ? 40.0 : 10.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle and title on the left side
          SizedBox(
            width: MediaQuery.of(context).size.width > 768 ? 180.0 : 40.0,
            child: Stack(
              children: [
                // Circle indicator
                Positioned(
                  left: MediaQuery.of(context).size.width > 768 ? 30.0 : 12.0,
                  top: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF303030)
                              : const Color(0xFFE5E5E5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode
                                ? const Color(0xFF505050)
                                : const Color(0xFFCCCCCC),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Title for large screens
                if (MediaQuery.of(context).size.width > 768)
                  Positioned(
                    left: 60,
                    top: 0,
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF808080),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title for small screens
                  if (MediaQuery.of(context).size.width <= 768)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ),
                  // Content
                  item.content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final exampleData = [
  TimelineEntry(
    title: '2023',
    content: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Started development of Aceternity UI components'),
      ),
    ),
  ),
  TimelineEntry(
    title: '2024',
    content: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Released the first version of the library'),
      ),
    ),
  ),
  TimelineEntry(
    title: '2025',
    content: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Expanded to mobile platforms with Flutter'),
      ),
    ),
  ),
];
