import 'package:flutter/material.dart';

class TimelineEntry {
  final String title;
  final TimelineItemContent content;
  final String date; // Add date to identify the year

  TimelineEntry({
    required this.title,
    required this.content,
    required this.date, // Make date a required parameter
  });
}

class TimelineItemContent {
  final String text;
  final List<String> images;
  final List<String>? checklistItems;

  TimelineItemContent({
    required this.text,
    required this.images,
    this.checklistItems,
  });
}

class TimelinePage extends StatefulWidget {
  final List<TimelineEntry> data;
  final double timelineHeight;

  const TimelinePage({
    super.key,
    required this.data,
    this.timelineHeight = 550.0,
  });

  @override
  State<TimelinePage> createState() => _TimelineState();
}

class _TimelineState extends State<TimelinePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  final GlobalKey _timelineKey = GlobalKey();
  double _timelineHeight = 0.0;

  // Map to store entries grouped by year
  Map<String, List<TimelineEntry>> _groupedEntries = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTimelineHeight();
    });

    // Group entries by year
    _groupEntries();
  }

  // Group timeline entries by year
  void _groupEntries() {
    _groupedEntries = {};

    for (var entry in widget.data) {
      // Extract year from the date
      final year = _extractYear(entry.date);

      if (!_groupedEntries.containsKey(year)) {
        _groupedEntries[year] = [];
      }

      _groupedEntries[year]!.add(entry);
    }
  }

  // Extract year from date string
  String _extractYear(String date) {
    // This assumes the date string contains a year that can be extracted
    // Simple check for common year formats
    if (date.contains("2024")) return "2024";
    if (date.contains("2025")) return "2025";

    // Try to find 4-digit numbers that could be years
    RegExp yearRegex = RegExp(r'\d{4}');
    final match = yearRegex.firstMatch(date);
    if (match != null) {
      return match.group(0) ?? "Unknown";
    }

    // Default case if we can't find a year
    return "Unknown";
  }

  void _updateTimelineHeight() {
    final RenderBox? box =
        _timelineKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      setState(() {
        _timelineHeight = box.size.height;
      });
    }
  }

  void _updateScrollProgress() {
    final double totalHeight = _scrollController.position.maxScrollExtent;
    if (totalHeight > 0) {
      setState(() {
        _scrollProgress = _scrollController.offset / totalHeight;
        if (_scrollProgress > 1.0) _scrollProgress = 1.0;
        if (_scrollProgress < 0.0) _scrollProgress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtextColor =
        isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;
    final Color timelineTitleColor = Colors.grey[500]!;

    // Sort years to ensure chronological order
    final sortedYears = _groupedEntries.keys.toList()..sort();

    return Container(
      color: backgroundColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            _updateScrollProgress();
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Changelog from my journey',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Create a timeline for each year
            for (final year in sortedYears)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year header
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                      child: Text(
                        year,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Timeline for this year
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      height: widget.timelineHeight,
                      child: YearTimeline(
                        entries: _groupedEntries[year]!,
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        timelineTitleColor: timelineTitleColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// New widget to handle individual year timelines
class YearTimeline extends StatefulWidget {
  final List<TimelineEntry> entries;
  final bool isDarkMode;
  final Color textColor;
  final Color subtextColor;
  final Color timelineTitleColor;

  const YearTimeline({
    super.key,
    required this.entries,
    required this.isDarkMode,
    required this.textColor,
    required this.subtextColor,
    required this.timelineTitleColor,
  });

  @override
  State<YearTimeline> createState() => _YearTimelineState();
}

class _YearTimelineState extends State<YearTimeline> {
  final ScrollController _yearScrollController = ScrollController();
  double _scrollProgress = 0.0;
  final GlobalKey _timelineKey = GlobalKey();
  double _timelineHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _yearScrollController.addListener(_updateScrollProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTimelineHeight();
    });
  }

  void _updateTimelineHeight() {
    final RenderBox? box =
        _timelineKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      setState(() {
        _timelineHeight = box.size.height;
      });
    }
  }

  void _updateScrollProgress() {
    final double totalHeight = _yearScrollController.position.maxScrollExtent;
    if (totalHeight > 0) {
      setState(() {
        _scrollProgress = _yearScrollController.offset / totalHeight;
        if (_scrollProgress > 1.0) _scrollProgress = 1.0;
        if (_scrollProgress < 0.0) _scrollProgress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _yearScrollController.removeListener(_updateScrollProgress);
    _yearScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _updateScrollProgress();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _yearScrollController,
        child: Stack(
          key: _timelineKey,
          children: [
            // Timeline line
            Positioned(
              left: 24,
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
                      Colors.grey,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Animated progress line
            Positioned(
              left: 24,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 2,
                height: _timelineHeight * _scrollProgress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue,
                      Colors.purple,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Timeline content
            Column(
              children: widget.entries.map((item) {
                return TimelineItem(
                  title: item.title,
                  content: item.content,
                  date: item.date,
                  isDarkMode: widget.isDarkMode,
                  textColor: widget.textColor,
                  subtextColor: widget.subtextColor,
                  timelineTitleColor: widget.timelineTitleColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String title;
  final TimelineItemContent content;
  final String date; // Added date parameter
  final bool isDarkMode;
  final Color textColor;
  final Color subtextColor;
  final Color timelineTitleColor;

  const TimelineItem({
    super.key,
    required this.title,
    required this.content,
    required this.date, // Make date required
    required this.isDarkMode,
    required this.textColor,
    required this.subtextColor,
    required this.timelineTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node centered on the line and title for larger screens
          SizedBox(
            width: 80,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Centered node on the line
                Positioned(
                  left: 16, // Centered on the timeline line (24 + 1)
                  child: Container(
                    height: 16, // Further reduced size
                    width: 16, // Further reduced size
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        height: 6, // Smaller inner dot
                        width: 6, // Smaller inner dot
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 16), // Space for the node
                    if (MediaQuery.of(context).size.width > 600)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 20.0),
                        child: Text(
                          // Display month from date
                          _extractMonth(date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: timelineTitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title for mobile
                  if (MediaQuery.of(context).size.width <= 600)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        // Show month for mobile view
                        _extractMonth(date),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: timelineTitleColor,
                        ),
                      ),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Diagnosis/Title
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          // Content text
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              content.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: subtextColor,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Checklist items if any
                  if (content.checklistItems != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: content.checklistItems!.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Image grid - commented out as in original code
                  // GridView.builder(
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   gridDelegate:
                  //       const SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 2,
                  //     crossAxisSpacing: 8.0,
                  //     mainAxisSpacing: 8.0,
                  //     childAspectRatio: 1.5,
                  //   ),
                  //   itemCount: content.images.length,
                  //   itemBuilder: (context, index) {
                  //     return ClipRRect(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //       child: Container(
                  //         decoration: BoxDecoration(
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withOpacity(0.1),
                  //               spreadRadius: 1,
                  //               blurRadius: 3,
                  //               offset: const Offset(0, 2),
                  //             ),
                  //           ],
                  //         ),
                  //         child: Image.asset(
                  //           content.images[index],
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  //     );
                  // },
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to extract month from date string
  String _extractMonth(String date) {
    // This method should extract the month from your date format
    // Adjust based on your actual date format
    if (date.contains("JAN")) return "JAN";
    if (date.contains("FEB")) return "FEB";
    if (date.contains("MAR")) return "MAR";
    if (date.contains("APR")) return "APR";
    if (date.contains("MAY")) return "MAY";
    if (date.contains("JUN")) return "JUN";
    if (date.contains("JUL")) return "JUL";
    if (date.contains("AUG")) return "AUG";
    if (date.contains("SEP")) return "SEP";
    if (date.contains("OCT")) return "OCT";
    if (date.contains("NOV")) return "NOV";
    if (date.contains("DEC")) return "DEC";

    // Default fallback
    return "N/A";
  }
}
