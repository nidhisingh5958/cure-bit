import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/features/features_api_repository/appointment/patient/post_patient_repository.dart';
import 'package:CuraDocs/features/patient/appointment/components/problem_selection_widget.dart';
import 'package:CuraDocs/features/patient/appointment/success_screen.dart';
import 'package:CuraDocs/utils/size_config.dart';
import 'package:CuraDocs/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:CuraDocs/common/components/colors.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

final String docCIN = 'dbfshd#455nchs';
final String docName = 'Dr. Sarah Johnson';
final String patientName = 'John Doe';
final String patientEmail = 'johndoe@gmail.com';

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

  final AudioPlayer audioPlayer = AudioPlayer();

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

  Future<void> _bookButtomPressed() async {
    if (isFormValid) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        final appoRepository = PatientAppointmentRepository();

        // Convert selected date to string format expected by API
        final String formattedDate =
            DateFormat('yyyy-MM-dd').format(selectedDate);

        // Get the selected time string properly
        final String selectedTime = timeSlots[selectedTimeIndex!]['time'];

        // Assuming repository.bookAppointment has been modified to return boolean success status
        // If you can't modify the repository class, use the Completer approach from the previous version
        bool bookingSuccessful = await appoRepository.bookAppointment(
          context,
          docName,
          docCIN,
          patientName,
          patientEmail,
          formattedDate,
          selectedTime,
        );

        // Close loading dialog
        Navigator.pop(context);

        if (bookingSuccessful) {
          // Only show success screen after successful API call
          setState(() {
            showSuccessScreen = true;
          });

          // Play sound effect only after successful booking
          _playSoundEffect();

          // Show success message
          showSnackBar(
            context: context,
            message: 'Appointment booked successfully!',
          );

          // Reset the form
          setState(() {
            selectedDate = DateTime.now();
            selectedTimeIndex = null;
            selectedProblems = [];
          });

          // Hide the success screen after a delay
          await Future.delayed(Duration(seconds: 3));
          setState(() {
            showSuccessScreen = false;
          });
        }
      } catch (e) {
        // Close loading dialog if still open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show error message to the user
        showSnackBar(
          context: context,
          message: 'Error booking appointment: ${e.toString()}',
        );
        debugPrint('Appointment booking error: $e');
      }
    } else {
      // Inform user about incomplete form
      showSnackBar(
        context: context,
        message: 'Please complete all required fields',
      );
    }
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
    await audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig().init(context);

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
        body: showSuccessScreen ? SucessScreen() : _buildBookingForm(),
      ),
    );
  }

  Widget _buildBookingForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildDoctorProfile(context),
          SizedBox(height: getProportionateScreenHeight(24)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Choose a date',
                  style: TextStyle(
                    fontSize: getProportionateScreenWidth(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(12)),
                _buildCalendar(),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(24)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(8)),
                      _buildTimeSelection(),
                    ],
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(8)),
                      _buildAddressDisplay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(24)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Problem',
                  style: TextStyle(
                    fontSize: getProportionateScreenWidth(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),
                _buildProblemSelection(),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(32)),
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
    return buildResponsiveCalendar(
      context,
      selectedDate: selectedDate,
      onDateSelected: (date) {
        setState(() {
          selectedDate = date;
        });
      },
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(20)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedTimeIndex,
          hint: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(12),
            ),
            child: Text(
              'Select time',
              style: TextStyle(
                fontSize: getProportionateScreenWidth(14),
              ),
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(12)),
            child: Icon(
              Icons.arrow_drop_down,
              size: getProportionateScreenWidth(24),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedTimeIndex = value;
            });
          },
          items: List.generate(timeSlots.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(12),
                ),
                child: Text(
                  timeSlots[index]['time'],
                  style: TextStyle(
                    fontSize: getProportionateScreenWidth(14),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAddressDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenHeight(14),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(20)),
        color: Colors.grey[100],
      ),
      child: Text(
        selectedTimeIndex != null
            ? timeSlots[selectedTimeIndex!]['address']
            : 'Address will be shown here',
        style: TextStyle(
          fontSize: getProportionateScreenWidth(14),
          color: selectedTimeIndex != null ? Colors.black : Colors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProblemSelection() {
    return ProblemSelectionWidget(
      availableProblems: problems,
      selectedProblems: selectedProblems,
      onProblemsChanged: (updatedProblems) {
        setState(() {
          selectedProblems = updatedProblems;
        });
      },
      maxProblems: 5,
    );
  }

  Widget _buildBookButton() {
    return Center(
      child: SizedBox(
        width: getProportionateScreenWidth(200),
        height: getProportionateScreenHeight(45),
        child: ElevatedButton(
          onPressed: isFormValid ? _bookButtomPressed : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(getProportionateScreenWidth(20)),
            ),
            elevation: 2,
            backgroundColor:
                isFormValid ? Theme.of(context).primaryColor : Colors.grey[300],
          ),
          child: Text(
            'Book',
            style: TextStyle(
              fontSize: getProportionateScreenWidth(16),
              fontWeight: FontWeight.bold,
              color: isFormValid ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

// Import the responsive calendar widget method
Widget buildResponsiveCalendar(
  BuildContext context, {
  required DateTime selectedDate,
  required Function(DateTime) onDateSelected,
}) {
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

  // Calculate responsive sizes
  final daySize = getProportionateScreenWidth(30); // Base size for day cells
  final dayTextSize = getProportionateScreenWidth(12); // Text size for days
  final headerTextSize = getProportionateScreenWidth(16); // Size for month name
  final weekdayTextSize =
      getProportionateScreenWidth(10); // Size for weekday labels

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: getProportionateScreenWidth(24),
            ),
            onPressed: () {
              // Previous month
            },
          ),
          Text(
            DateFormat('MMMM').format(DateTime(currentYear, currentMonth)),
            style: TextStyle(
              fontSize: headerTextSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: getProportionateScreenWidth(24),
            ),
            onPressed: () {
              // Next month
            },
          ),
        ],
      ),
      SizedBox(height: getProportionateScreenHeight(8)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((day) {
          return SizedBox(
            width: daySize,
            child: Text(
              day,
              style: TextStyle(
                fontSize: weekdayTextSize,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
      SizedBox(height: getProportionateScreenHeight(8)),
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: getProportionateScreenHeight(2),
          crossAxisSpacing: getProportionateScreenWidth(2),
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
                    onDateSelected(date);
                  },
            child: Container(
              margin: EdgeInsets.all(getProportionateScreenWidth(2)),
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
                    fontSize: dayTextSize,
                    color: isSelected
                        ? Colors.white
                        : isPastDate
                            ? Colors.grey[400]
                            : isToday
                                ? Theme.of(context).primaryColor
                                : null,
                    fontWeight: isSelected || isToday ? FontWeight.bold : null,
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
