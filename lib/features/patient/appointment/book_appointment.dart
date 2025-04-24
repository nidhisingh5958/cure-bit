import 'package:CuraDocs/components/app_header.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/components/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class BookAppointment extends StatefulWidget {
  const BookAppointment({super.key});

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  // State variables
  DateTime selectedDate = DateTime.now();
  int? selectedTimeIndex;
  int? selectedAddressIndex;
  List<String> selectedProblems = [];
  bool showSuccessScreen = false;
  final AudioPlayer audioPlayer =
      AudioPlayer(); // Audio player for sound effects

  final FocusNode _focusNode = FocusNode();
  bool isExpanded = false;
  String query = '';

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen for changes to update the isExpanded state
    _textController.addListener(() {
      setState(() {
        isExpanded = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    // Clean up resources
    _textController.dispose();
    _focusNode.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  // delete items function to clear the text
  void _deleteItems() {
    setState(() {
      _textController.clear();
      query = '';
      isExpanded = false;
    });
  }

  // Time slots with associated addresses
  final List<Map<String, dynamic>> timeSlots = [
    {
      'time': '10:30 am',
      'address': 'Plot 45, Medanta Hospital Gurgaon',
    },
    {
      'time': '11:45 am',
      'address': '22B, Apollo Clinic, Sector 14',
    },
    {
      'time': '2:15 pm',
      'address': 'Max Healthcare, Saket',
    },
  ];

  // Problems
  final List<String> problems = [
    'Headache',
    'Vomiting',
    'Fever',
    'Cough',
    'Cold',
    'Stomach ache',
    'Diarrhea',
    'Constipation',
    'Back pain',
    'Joint pain',
    'Muscle pain',
    'Chest pain',
    'Shortness of breath'
  ];

  // Check if all fields are filled
  bool get isFormValid {
    return selectedDate.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        selectedTimeIndex != null &&
        selectedProblems.isNotEmpty;
  }

  void _playSoundEffect() async {
    // You'll need to add your sound file to the assets and configure pubspec.yaml
    await audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppHeader(
          title: 'Book Appointment',
          onBackPressed: () {
            Navigator.pop(context);
          },
          elevation: 0,
          backgroundColor: transparent,
        ),
        body: showSuccessScreen ? _buildSuccessScreen() : _buildBookingForm(),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.black,
          ),
          SizedBox(height: 20),
          Text(
            'Your appointment has been',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'booked successfully',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Return Home',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildDoctorProfile(context),
          SizedBox(height: 24),
          Text(
            'Choose a date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          _buildCalendar(),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildTimeSelection(),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildAddressDisplay(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Problem',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          _buildProblemSelection(),
          SizedBox(height: 32),
          _buildBookButton(),
        ],
      ),
    );
  }

  Widget _buildDoctorProfile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey[200],
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr Sarah Johnson',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Cardiologist',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 5),
                      Text(
                        '5.0',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    // Get current month and year
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final currentDay = DateTime.now().day;

    // First day of the month
    final firstDay = DateTime(currentYear, currentMonth, 1);

    // Last day of the month
    final lastDay = DateTime(currentYear, currentMonth + 1, 0);

    // Number of days in the month
    final daysInMonth = lastDay.day;

    // Get day of week for first day (0 = Sunday, 1 = Monday, ...)
    final firstDayOfWeek = firstDay.weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                // Previous month
              },
            ),
            Text(
              DateFormat('MMMM').format(DateTime(currentYear, currentMonth)),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                // Next month
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((day) {
            return SizedBox(
              width: 30,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: firstDayOfWeek + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstDayOfWeek) {
              return Container(); // Empty cells before the first day
            }

            final day = index - firstDayOfWeek + 1;
            final date = DateTime(currentYear, currentMonth, day);
            final isToday = currentDay == day;
            final isPastDate =
                date.isBefore(DateTime.now().subtract(Duration(days: 1)));
            final isSelected = selectedDate.day == day &&
                selectedDate.month == currentMonth &&
                selectedDate.year == currentYear;

            return GestureDetector(
              onTap: isPastDate
                  ? null // Disable past dates
                  : () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isPastDate
                          ? Colors.grey[200]
                          : null,
                  border: isToday && !isSelected
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        )
                      : null,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isPastDate
                              ? Colors.grey[400]
                              : isToday
                                  ? Theme.of(context).primaryColor
                                  : null,
                      fontWeight:
                          isSelected || isToday ? FontWeight.bold : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedTimeIndex,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('Select time'),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(Icons.arrow_drop_down),
          ),
          onChanged: (value) {
            setState(() {
              selectedTimeIndex = value;
              // Synchronize with address
            });
          },
          items: List.generate(timeSlots.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(timeSlots[index]['time']),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAddressDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
      ),
      child: Text(
        selectedTimeIndex != null
            ? timeSlots[selectedTimeIndex!]['address']
            : 'Address will be shown here',
        style: TextStyle(
          fontSize: 14,
          color: selectedTimeIndex != null ? Colors.black : Colors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProblemSelection() {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        focusNode: _focusNode,
        controller: _textController, // Use the controller
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  onPressed: _deleteItems,
                )
              else
                Icon(
                  Icons.mic,
                  color: black,
                  size: 20,
                ),
            ],
          ),
          hintText: "Search for doctors",
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
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
    );
  }

  // child: Wrap(
  //   spacing: 8.0,
  //   runSpacing: 8.0,
  //   children: problems.map((problem) {
  //     final isSelected = selectedProblems.contains(problem);
  //     return FilterChip(
  //       label: Text(problem),
  //       selected: isSelected,
  //       onSelected: (selected) {
  //         setState(() {
  //           if (selected) {
  //             selectedProblems.add(problem);
  //           } else {
  //             selectedProblems.remove(problem);
  //           }
  //         });
  //       },
  //       backgroundColor: Colors.white,
  //       selectedColor: Theme.of(context).primaryColor.withValues(0.2),
  //       checkmarkColor: Theme.of(context).primaryColor,
  //       labelStyle: TextStyle(
  //         color: isSelected ? Theme.of(context).primaryColor : Colors.black,
  //       ),
  //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     );
  //   }).toList(),
  // ),

  Widget _buildBookButton() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 45,
        child: ElevatedButton(
          onPressed: isFormValid
              ? () {
                  // Play success sound
                  _playSoundEffect();

                  // Show success screen
                  setState(() {
                    showSuccessScreen = true;
                  });
                }
              : null, // Button is disabled if form is not valid
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 2,
            backgroundColor:
                isFormValid ? Theme.of(context).primaryColor : Colors.grey[300],
          ),
          child: Text(
            'Book',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isFormValid ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
