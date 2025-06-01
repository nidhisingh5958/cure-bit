import 'dart:math';
import 'package:CureBit/common/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CureBit/app/features_api_repository/search/internal_search/patient_search_provider.dart';

class PatientSearch extends ConsumerStatefulWidget {
  final String doctorCIN;

  const PatientSearch({
    Key? key,
    required this.doctorCIN,
  }) : super(key: key);

  @override
  ConsumerState<PatientSearch> createState() => _PatientSearchState();
}

class _PatientSearchState extends ConsumerState<PatientSearch>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late StateNotifierProvider<PatientSearchNotifier, PatientSearchState>
      _provider;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style to ensure proper status bar appearance
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize the provider safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = patientSearchProvider(widget.doctorCIN);
      // Set up listener for text changes
      _searchController.addListener(_onSearchChanged);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Debounce implementation
  DateTime _lastChanged = DateTime.now();
  Future<void> _onSearchChanged() async {
    // Guard against null provider
    if (!mounted) return;

    final now = DateTime.now();
    _lastChanged = now;

    // Set searching state
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });

    // Wait for 500ms (debounce)
    await Future.delayed(const Duration(milliseconds: 500));

    // Only proceed if this is still the most recent change and widget is still mounted
    if (now == _lastChanged && mounted) {
      try {
        ref.read(_provider.notifier).searchPatients(_searchController.text);
      } catch (e) {
        // Handle error if provider is not ready
        debugPrint('Search provider error: $e');
      }
    }
  }

  void _refreshIndex() {
    try {
      if (mounted) {
        // Start refresh animation
        _animationController.repeat();
        ref.read(_provider.notifier).refreshSearchIndex().then((_) {
          // Stop animation when done
          if (mounted) {
            _animationController.stop();
            _animationController.reset();
          }
        });
      }
    } catch (e) {
      debugPrint('Refresh index error: $e');
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    try {
      ref.read(_provider.notifier).searchPatients('');
    } catch (e) {
      debugPrint('Clear search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = black;
    final backgroundColor = theme.scaffoldBackgroundColor;

    // Safely access the provider
    try {
      final state = ref.watch(_provider);

      return Scaffold(
        backgroundColor: backgroundColor,
        // Using SafeArea inside the body
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, primaryColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                child: Row(
                  children: [
                    _buildSearchBar(context, primaryColor),
                    const SizedBox(width: 12),
                    _buildRefreshButton(primaryColor),
                  ],
                ),
              ),
              if (state.isLoading)
                const Expanded(
                    child: Center(
                  child: CircularProgressIndicator(),
                ))
              else if (state.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: theme.colorScheme.errorContainer.withOpacity(0.7),
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.errorMessage,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: _buildSearchResults(state, theme),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      // Fallback UI when provider is not ready yet
      return Material(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, primaryColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                child: Row(
                  children: [
                    _buildSearchBar(context, primaryColor),
                    const SizedBox(width: 12),
                    _buildRefreshButton(primaryColor),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search interface initializing...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_alt_rounded,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Patient Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  color: primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Doctor ID: ${widget.doctorCIN.substring(0, min(8, widget.doctorCIN.length))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Color primaryColor) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name, ID or condition...',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: primaryColor,
            ),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                    color: Colors.grey.shade600,
                    tooltip: 'Clear search',
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RotationTransition(
        turns: _animation,
        child: IconButton(
          onPressed: _refreshIndex,
          icon: const Icon(Icons.refresh),
          color: Colors.white,
          tooltip: 'Refresh search results',
        ),
      ),
    );
  }

  Widget _buildSearchResults(PatientSearchState state, ThemeData theme) {
    if (state.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchController.text.isEmpty ? Icons.search : Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Enter a search term to find patients'
                  : 'No matching medical records found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try a different search term or refresh the index',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final result = state.searchResults[index];
        // Safely handle potentially null patient data
        if (result == null) {
          return const SizedBox.shrink();
        }
        return PatientResultCard(
          patientData: result,
          theme: theme,
          isFirst: index == 0,
          isLast: index == state.searchResults.length - 1,
        );
      },
    );
  }
}

class PatientResultCard extends StatelessWidget {
  final dynamic patientData;
  final ThemeData theme;
  final bool isFirst;
  final bool isLast;

  const PatientResultCard({
    Key? key,
    required this.patientData,
    required this.theme,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely extract patient information from the data
    // Use null-aware operators to prevent null exceptions
    final String name = patientData?['name'] ?? 'Unknown';
    final String id = patientData?['id'] ?? '';
    final String details = patientData?['details'] ?? 'No details available';

    // Generate initials for avatar
    final List<String> nameParts = name.split(' ');
    final String initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : name.length > 0
            ? name[0]
            : '?';

    // Determine patient severity/status color (mocked here)
    final int hash = name.hashCode;
    final List<Color> statusColors = [
      Colors.green.shade400, // Normal
      Colors.blue.shade400, // Follow-up
      Colors.amber.shade400, // Needs attention
      Colors.red.shade400, // Urgent
    ];
    final Color statusColor = statusColors[hash.abs() % statusColors.length];

    return Card(
      margin: EdgeInsets.only(
        bottom: isLast ? 16 : 12,
        top: isFirst ? 4 : 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to patient details or perform other actions
          // For example:
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => PatientDetailsScreen(patientId: id),
          //   ),
          // );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient avatar with indicators
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      initials.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Patient information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: $id',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Right arrow for navigation
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
