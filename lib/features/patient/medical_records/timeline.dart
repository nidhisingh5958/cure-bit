import 'package:CureBit/common/components/colors.dart';
import 'package:flutter/material.dart';

class TimelineEntry {
  final String title;
  final TimelineItemContent content;
  final String date;

  TimelineEntry({
    required this.title,
    required this.content,
    required this.date,
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
                  vertical: 16.0, // Reduced vertical padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Timeline',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: black.withValues(alpha: .8),
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
                      padding: const EdgeInsets.fromLTRB(
                          16.0, 8.0, 16.0, 4.0), // Reduced padding
                      child: Text(
                        year,
                        style: TextStyle(
                          fontSize: 28, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 20, 6, 29),
                        ),
                      ),
                    ),
                    // Timeline for this year
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: 12.0), // Reduced margin
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

// Year timeline widget
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
              left: 20, // Adjusted position closer to the edge
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
                      grey800,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Animated progress line
            Positioned(
              left: 20, // Matched with timeline line
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
                return ExpandableTimelineItem(
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

// Expandable Timeline Item
class ExpandableTimelineItem extends StatefulWidget {
  final String title;
  final TimelineItemContent content;
  final String date;
  final bool isDarkMode;
  final Color textColor;
  final Color subtextColor;
  final Color timelineTitleColor;

  const ExpandableTimelineItem({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.isDarkMode,
    required this.textColor,
    required this.subtextColor,
    required this.timelineTitleColor,
  });

  @override
  State<ExpandableTimelineItem> createState() => _ExpandableTimelineItemState();
}

class _ExpandableTimelineItemState extends State<ExpandableTimelineItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Reduced bottom padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node and month indicator
          SizedBox(
            width: 60, // Reduced width for the timeline node area
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Centered node on the line
                Positioned(
                  left: 15, // Centered on the timeline line
                  child: Container(
                    height: 12, // Smaller node
                    width: 12, // Smaller node
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? white : black,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 182, 77, 232)
                              .withValues(alpha: .2),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        height: 4, // Smaller inner dot
                        width: 4, // Smaller inner dot
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Month label
                Column(
                  children: [
                    const SizedBox(height: 18), // Reduced space for the node
                    if (MediaQuery.of(context).size.width > 600)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                        child: Text(
                          _extractMonth(widget.date),
                          style: TextStyle(
                            fontSize: 14, // Smaller font size
                            fontWeight: FontWeight.bold,
                            color: widget.timelineTitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 12.0), // Reduced right padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month indicator for mobile view
                  if (MediaQuery.of(context).size.width <= 600)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 4.0), // Reduced padding
                      child: Text(
                        _extractMonth(widget.date),
                        style: TextStyle(
                          fontSize: 14, // Smaller font
                          fontWeight: FontWeight.bold,
                          color: widget.timelineTitleColor,
                        ),
                      ),
                    ),

                  // Clickable and expandable container
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.grey[900] : white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: black.withValues(alpha: .08),
                            spreadRadius: 0.5,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), // Reduced padding
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row with expand indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 16, // Smaller title font
                                      fontWeight: FontWeight.bold,
                                      color: widget.textColor,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: widget.subtextColor,
                                  size: 18,
                                ),
                              ],
                            ),

                            // Preview text (always visible)
                            if (!_isExpanded)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  widget.content.text,
                                  style: TextStyle(
                                    fontSize: 12, // Smaller content font
                                    color: widget.subtextColor,
                                  ),
                                  maxLines:
                                      1, // Limited to 1 line when collapsed
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            // Expanded content
                            if (_isExpanded) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.content.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.subtextColor,
                                ),
                              ),

                              // Checklist items if any
                              if (widget.content.checklistItems != null) ...[
                                const SizedBox(height: 12),
                                ...widget.content.checklistItems!.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: widget.isDarkMode
                                              ? Colors.blue[300]
                                              : Colors.blue[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: widget.subtextColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],

                              // Image grid - commented out as in original code but structure kept for reference
                              // if (widget.content.images.isNotEmpty) ...[
                              //   const SizedBox(height: 12),
                              //   GridView.builder(
                              //     shrinkWrap: true,
                              //     physics: const NeverScrollableScrollPhysics(),
                              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              //       crossAxisCount: 2,
                              //       crossAxisSpacing: 8.0,
                              //       mainAxisSpacing: 8.0,
                              //       childAspectRatio: 1.5,
                              //     ),
                              //     itemCount: widget.content.images.length,
                              //     itemBuilder: (context, index) {
                              //       return ClipRRect(
                              //         borderRadius: BorderRadius.circular(8.0),
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //             boxShadow: [
                              //               BoxShadow(
                              //                 color: Colors.black.withValues(alpha: .1),
                              //                 spreadRadius: 1,
                              //                 blurRadius: 3,
                              //                 offset: const Offset(0, 2),
                              //               ),
                              //             ],
                              //           ),
                              //           child: Image.asset(
                              //             widget.content.images[index],
                              //             fit: BoxFit.cover,
                              //           ),
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
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
