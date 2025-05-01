import 'package:flutter/material.dart';
import 'package:CuraDocs/utils/size_config.dart';

class ProblemSelectionWidget extends StatefulWidget {
  final List<String> availableProblems;
  final List<String> selectedProblems;
  final Function(List<String>) onProblemsChanged;
  final int maxProblems;

  const ProblemSelectionWidget({
    super.key,
    required this.availableProblems,
    required this.selectedProblems,
    required this.onProblemsChanged,
    this.maxProblems = 5,
  });

  @override
  State<ProblemSelectionWidget> createState() => _ProblemSelectionWidgetState();
}

class _ProblemSelectionWidgetState extends State<ProblemSelectionWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownVisible = false;
  String _searchQuery = '';
  List<String> _filteredProblems = [];

  @override
  void initState() {
    super.initState();
    _filteredProblems = widget.availableProblems;

    // Show dropdown when text field is focused
    _focusNode.addListener(() {
      setState(() {
        _isDropdownVisible = _focusNode.hasFocus && _searchQuery.isNotEmpty;
      });
    });

    // Update filtered problems when text changes
    _textController.addListener(_updateFilteredProblems);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateFilteredProblems() {
    setState(() {
      _searchQuery = _textController.text.toLowerCase();
      _isDropdownVisible = _focusNode.hasFocus && _searchQuery.isNotEmpty;

      if (_searchQuery.isEmpty) {
        _filteredProblems = widget.availableProblems;
      } else {
        _filteredProblems = widget.availableProblems
            .where((problem) => problem.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  void _addProblem(String problem) {
    if (!widget.selectedProblems.contains(problem) &&
        widget.selectedProblems.length < widget.maxProblems) {
      final updatedProblems = [...widget.selectedProblems, problem];
      widget.onProblemsChanged(updatedProblems);

      // Clear the text and reset dropdown
      _textController.clear();
      setState(() {
        _isDropdownVisible = false;
        _searchQuery = '';
      });
    }
  }

  void _removeProblem(String problem) {
    final updatedProblems =
        widget.selectedProblems.where((p) => p != problem).toList();

    widget.onProblemsChanged(updatedProblems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected problems chips
        if (widget.selectedProblems.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: getProportionateScreenHeight(12),
            ),
            child: Wrap(
              spacing: getProportionateScreenWidth(8),
              runSpacing: getProportionateScreenHeight(8),
              children: widget.selectedProblems.map((problem) {
                return _buildSelectedProblemChip(problem);
              }).toList(),
            ),
          ),

        // Search input field
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenHeight(12),
            ),
            suffixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: getProportionateScreenWidth(20),
            ),
            hintText: "Search or add problems",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: getProportionateScreenWidth(14),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(getProportionateScreenWidth(10)),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          style: TextStyle(
            fontSize: getProportionateScreenWidth(14),
            color: Colors.black,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              // Allow adding custom problem if not in the list
              if (!widget.availableProblems.contains(value) &&
                  !widget.selectedProblems.contains(value)) {
                _addProblem(value);
              }
            }
          },
        ),

        // Info text for max problems
        Padding(
          padding: EdgeInsets.only(
            top: getProportionateScreenHeight(4),
            left: getProportionateScreenWidth(4),
          ),
          child: Text(
            "Max ${widget.maxProblems} problems (${widget.selectedProblems.length}/${widget.maxProblems})",
            style: TextStyle(
              color: Colors.grey,
              fontSize: getProportionateScreenWidth(12),
            ),
          ),
        ),

        // Dropdown suggestions
        if (_isDropdownVisible && _filteredProblems.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: getProportionateScreenHeight(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(getProportionateScreenWidth(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: getProportionateScreenHeight(200),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                  vertical: getProportionateScreenHeight(8)),
              itemCount: _filteredProblems.length,
              itemBuilder: (context, index) {
                final problem = _filteredProblems[index];
                final isSelected = widget.selectedProblems.contains(problem);

                return ListTile(
                  dense: true,
                  title: Text(
                    problem,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(14),
                      color: isSelected ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: getProportionateScreenWidth(18),
                        )
                      : null,
                  enabled: !isSelected,
                  onTap: isSelected ? null : () => _addProblem(problem),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedProblemChip(String problem) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(16)),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(12),
        vertical: getProportionateScreenHeight(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            problem,
            style: TextStyle(
              fontSize: getProportionateScreenWidth(14),
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(4)),
          GestureDetector(
            onTap: () => _removeProblem(problem),
            child: Icon(
              Icons.close,
              size: getProportionateScreenWidth(16),
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
