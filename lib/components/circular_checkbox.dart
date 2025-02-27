import 'package:flutter/material.dart';

class CircularCheckbox extends StatefulWidget {
  const CircularCheckbox({
    super.key,
    this.isChecked = false,
    this.size,
    this.onChanged,
  });

  final bool isChecked;
  final double? size;
  final Function(bool)? onChanged;

  @override
  CircularCheckboxState createState() => CircularCheckboxState();
}

class CircularCheckboxState extends State<CircularCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  void didUpdateWidget(CircularCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      _isChecked = widget.isChecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(_isChecked);
        }
      },
      child: Container(
        width: widget.size ?? 25.0,
        height: widget.size ?? 25.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isChecked
                ? Theme.of(context).primaryColor
                : const Color(0xffE5E7EB),
            width: 2.0,
          ),
        ),
        child: _isChecked
            ? Center(
                child: Container(
                  width: (widget.size ?? 25.0) * 0.5,
                  height: (widget.size ?? 25.0) * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
