import 'package:CureBit/common/components/app_header.dart';
import 'package:CureBit/common/components/colors.dart';
import 'package:CureBit/common/components/pop_up.dart';
import 'package:CureBit/features/doctor/appointment/components/animated_fab.dart';
import 'package:CureBit/services/features_api_repository/appointment/doctor/get/get_doctor_repository.dart';
import 'package:CureBit/services/user/user_singleton.dart';
import 'package:CureBit/services/user/user_synchronization.dart';
import 'package:CureBit/features/doctor/patient_navigation_utility.dart';
import 'package:CureBit/utils/providers/user_provider.dart';
import 'package:CureBit/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class Patient {
  final String name;
  final String imagePath;
  final String consultationType;
  final String time;
  final bool isNext;
  final String id;
  final String appointmentDate;
  final String patientCin;

  Patient({
    required this.name,
    required this.imagePath,
    required this.consultationType,
    required this.time,
    this.isNext = false,
    required this.id,
    required this.appointmentDate,
    required this.patientCin,
  });

  // Factory constructor to create Patient from API response
  factory Patient.fromAppointment(Map<String, dynamic> appointmentData) {
    // Extract appointment type and set appropriate icon
    final String consultationType = appointmentData['type'] == 'video'
        ? 'Video Consultation'
        : 'In-Clinic Consultation';

    // Format time properly
    String time = appointmentData['time'] ?? '00:00';

    // Handle date formatting
    String appointmentDate = appointmentData['date'] ?? '2023-01-01';

    return Patient(
      id: appointmentData['id']?.toString() ?? '',
      name: appointmentData['patient_name'] ?? 'Unknown Patient',
      imagePath: appointmentData['patient_image'] ?? '',
      consultationType: consultationType,
      time: time,
      appointmentDate: appointmentDate,
      patientCin:
          appointmentData['patient_cin'] ?? appointmentData['patient_id'] ?? '',
      isNext: false,
    );
  }

  Patient copyWith({
    String? name,
    String? imagePath,
    String? consultationType,
    String? time,
    bool? isNext,
    String? id,
    String? appointmentDate,
    String? patientCin,
  }) {
    return Patient(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      consultationType: consultationType ?? this.consultationType,
      time: time ?? this.time,
      isNext: isNext ?? this.isNext,
      id: id ?? this.id,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      patientCin: patientCin ?? this.patientCin,
    );
  }
}

class DoctorScheduleScreen extends ConsumerStatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  ConsumerState<DoctorScheduleScreen> createState() =>
      _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends ConsumerState<DoctorScheduleScreen> {
  final DoctorGetAppointmentRepository _repository =
      DoctorGetAppointmentRepository();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String _currentDate = DateFormat('EEEE, d MMM').format(DateTime.now());
  DateTime _selectedDate = DateTime.now();
  bool _isViewingPreviousAppointments = false;

  // Get doctor's CIN from either provider or singleton
  String get _doctorCIN {
    // First try to get from provider
    final userFromProvider = ref.read(userProvider);
    if (userFromProvider != null && userFromProvider.cin.isNotEmpty) {
      return userFromProvider.cin;
    }

    // Fall back to singleton if provider is not available
    return UserSingleton().user.cin;
  }

  @override
  void initState() {
    super.initState();
    // We need to defer this to after initState completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser();
      _loadAppointments();
    });
  }

  // Initialize user data
  Future<void> _initializeUser() async {
    // Ensure the UserSingleton is initialized and in sync with provider
    await UserSynchronizer.initialize(ref);
  }

  // Method to navigate to patient profile using the utility
  void _navigateToPatientProfile(Patient patient) {
    // Use the navigation utility instead of custom logic
    PatientNavigationUtils.navigateFromPatientObject(
      context,
      patient,
      showErrorSnackbar: true,
    );
  }

  // Method to show patient options menu
  void _showPatientOptionsMenu(BuildContext context, Patient patient) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: patient.imagePath.isNotEmpty
                        ? AssetImage(patient.imagePath)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: patient.imagePath.isEmpty
                        ? Text(
                            patient.name.isNotEmpty ? patient.name[0] : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          patient.consultationType,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildOptionTile(
                icon: Icons.person_outline,
                title: 'View Profile',
                subtitle: 'View patient\'s complete profile',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPatientProfile(patient);
                },
              ),
              _buildOptionTile(
                icon: Icons.message_outlined,
                title: 'Send Message',
                subtitle: 'Chat with the patient',
                onTap: () {
                  //   redirect to messaging app
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Messaging ${patient.name}...')),
                  );
                },
              ),
              if (!_isViewingPreviousAppointments)
                _buildOptionTile(
                  icon: Icons.videocam_outlined,
                  title: 'Start Call',
                  subtitle: 'Begin video consultation',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle start call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Starting call with ${patient.name}...')),
                    );
                  },
                ),
              if (_isViewingPreviousAppointments)
                _buildOptionTile(
                  icon: Icons.description_outlined,
                  title: 'Medical Records',
                  subtitle: 'View consultation notes',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle medical records
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Viewing records for ${patient.name}')),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Method to load appointments from repository
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _isViewingPreviousAppointments = false;
    });

    try {
      final appointments = await _repository.getDoctorAppointments(_doctorCIN);

      if (appointments.isNotEmpty) {
        // Convert appointments to Patient objects
        final List<Patient> patientList = appointments
            .map((appointment) => Patient.fromAppointment(appointment))
            .toList();

        // Sort appointments by time
        patientList.sort((a, b) {
          // First compare dates
          final dateComparison = a.appointmentDate.compareTo(b.appointmentDate);
          if (dateComparison != 0) return dateComparison;

          // If same date, compare times
          return a.time.compareTo(b.time);
        });

        // Mark the next upcoming appointment
        if (patientList.isNotEmpty) {
          final now = DateTime.now();

          // Find the first appointment that is after the current time
          for (int i = 0; i < patientList.length; i++) {
            final patient = patientList[i];

            // Parse appointment date and time
            final appointmentDateTime = _parseAppointmentDateTime(
                patient.appointmentDate, patient.time);

            if (appointmentDateTime.isAfter(now)) {
              // Update using copyWith to preserve immutability
              patientList[i] = patient.copyWith(isNext: true);
              break;
            }
          }
        }

        setState(() {
          _patients = patientList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _patients = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading appointments: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Parse appointment date time string to DateTime object
  DateTime _parseAppointmentDateTime(String date, String time) {
    try {
      final parts = date.split('-');
      final timeParts = time.split(':');

      // Ensure we have valid parts
      if (parts.length == 3 && timeParts.length >= 2) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
    } catch (e) {
      debugPrint('Error parsing date time: $e');
    }

    // Return current time if parsing fails
    return DateTime.now();
  }

  // Method to refresh appointments
  Future<void> _refreshAppointments() async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    // Delete cached appointments
    await _repository.deleteCachedAppointments(context, _doctorCIN);

    // Reload appointments based on current view
    if (_isViewingPreviousAppointments) {
      await _loadPreviousAppointments(shouldRefresh: true);
    } else {
      await _loadAppointments();
    }
  }

  // Method to load previous appointments
  Future<void> _loadPreviousAppointments({bool shouldRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _isViewingPreviousAppointments = true;
    });

    try {
      // If refresh is requested, call the refresh method first
      if (shouldRefresh) {
        final refreshed = await _repository.refreshPreviousAppointments(
          context,
          _doctorCIN,
        );

        if (!refreshed) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final previousAppointments =
          await _repository.getDoctorPreviousAppointments(_doctorCIN);

      if (previousAppointments.isNotEmpty) {
        // Convert appointments to Patient objects
        final List<Patient> patientList = previousAppointments
            .map((appointment) => Patient.fromAppointment(appointment))
            .toList();

        // Sort by date and time (most recent first for previous appointments)
        patientList.sort((a, b) {
          final dateComparisonDesc =
              b.appointmentDate.compareTo(a.appointmentDate);
          if (dateComparisonDesc != 0) return dateComparisonDesc;
          return b.time.compareTo(a.time);
        });

        setState(() {
          _patients = patientList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _patients = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading previous appointments: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle date selection
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentDate = DateFormat('EEEE, d MMM').format(date);
      _isViewingPreviousAppointments = false;
    });

    // Reload appointments for this date
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: _isViewingPreviousAppointments
            ? 'Previous Appointments'
            : 'Appointments',
        onDetailPressed: () => context.goNamed(
          RouteConstants.doctorSchedulingAppointmentDetails,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: _refreshAppointments,
          ),
          IconButton(
            icon: const Icon(LucideIcons.circleEllipsis),
            onPressed: () {
              PopUp.buildPopupMenu(
                context,
                onSelected: (value) {
                  if (value == 'assign') {
                    context.goNamed(
                        RouteConstants.doctorSchedulingAppointmentDetails);
                  } else if (value == 'past') {
                    _loadPreviousAppointments();
                  } else if (value == 'current') {
                    _loadAppointments();
                  } else if (value == 'refresh_past') {
                    _loadPreviousAppointments(shouldRefresh: true);
                  } else if (value == 'info') {
                    // Handle help action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Help information coming soon')),
                    );
                  }
                },
                optionsList: [
                  {'assign': 'Scheduling Details'},
                  {'current': 'Current Appointments'},
                  {'past': 'Previous Appointments'},
                  {'refresh_past': 'Refresh Previous Appointments'},
                  {'info': 'Help'},
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: !_isViewingPreviousAppointments
          ? AnimatedFloatingActionButton(
              onNewAppointment: () {
                // Handle new appointment action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating new appointment...')),
                );
              },
              onReschedule: () {
                // Handle reschedule action
                context.goNamed(RouteConstants.doctorRescheduleAppointment);
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date section - only show when viewing current appointments
              if (!_isViewingPreviousAppointments)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _currentDate,
                          style: TextStyle(
                            color: black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: transparent, width: 1),
                      ),
                      child: IconButton(
                        icon: Icon(LucideIcons.calendar, color: black),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          ).then((date) {
                            if (date != null) {
                              _onDateSelected(date);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),

              if (!_isViewingPreviousAppointments) const SizedBox(height: 16),

              // Header with refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isViewingPreviousAppointments
                        ? 'Previous Appointments'
                        : 'Today\'s Appointments',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(LucideIcons.refreshCcw, size: 18),
                    label: const Text('Refresh'),
                    onPressed: _refreshAppointments,
                  ),
                ],
              ),

              // Toggle between current and previous appointments
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ChoiceChip(
                        label: const Text('Current'),
                        selected: !_isViewingPreviousAppointments,
                        onSelected: (selected) {
                          if (selected) {
                            _loadAppointments();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Previous'),
                        selected: _isViewingPreviousAppointments,
                        onSelected: (selected) {
                          if (selected) {
                            _loadPreviousAppointments();
                          }
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Loading indicator or appointments list
              _isLoading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _patients.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isViewingPreviousAppointments
                                      ? 'No previous appointments found'
                                      : 'No appointments found for today',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(LucideIcons.refreshCcw),
                                  label: const Text('Refresh'),
                                  onPressed: _refreshAppointments,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshAppointments,
                            child: ListView.builder(
                              itemCount: _patients.length,
                              itemBuilder: (context, index) {
                                final patient = _patients[index];

                                // Next appointment card
                                if (patient.isNext &&
                                    !_isViewingPreviousAppointments) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.grey.withValues(alpha: .1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Next Appointment',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                patient.time,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () =>
                                                    _navigateToPatientProfile(
                                                        patient),
                                                child: CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage: patient
                                                          .imagePath.isNotEmpty
                                                      ? AssetImage(
                                                          patient.imagePath)
                                                      : null,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: patient
                                                          .imagePath.isEmpty
                                                      ? Text(
                                                          patient.name
                                                                  .isNotEmpty
                                                              ? patient.name[0]
                                                              : '?',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _navigateToPatientProfile(
                                                          patient),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        patient.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            patient.consultationType
                                                                    .contains(
                                                                        'Video')
                                                                ? Icons.videocam
                                                                : Icons
                                                                    .home_work,
                                                            size: 20,
                                                            color: black,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            patient
                                                                .consultationType,
                                                            style: TextStyle(
                                                              color: grey600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    LucideIcons.messageCircle,
                                                    color: black,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    // redirect to whatsapp or messaging app
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor: grey600,
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      side: BorderSide(
                                                          color: grey600),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: grey800,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                  ),
                                                  child:
                                                      const Text('Start Call'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }

                                // Regular appointment item
                                return GestureDetector(
                                  onTap: () =>
                                      _showPatientOptionsMenu(context, patient),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.grey.withValues(alpha: .1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: [
                                                Text(
                                                  patient.time.split(' - ')[0],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: patient.isNext
                                                        ? black
                                                        : grey600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                if (_isViewingPreviousAppointments)
                                                  Text(
                                                    _formatAppointmentDate(
                                                        patient
                                                            .appointmentDate),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: grey600,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () =>
                                                _navigateToPatientProfile(
                                                    patient),
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundImage:
                                                  patient.imagePath.isNotEmpty
                                                      ? AssetImage(
                                                          patient.imagePath)
                                                      : null,
                                              backgroundColor: Colors.grey[300],
                                              child: patient.imagePath.isEmpty
                                                  ? Text(
                                                      patient.name.isNotEmpty
                                                          ? patient.name[0]
                                                          : '?',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _navigateToPatientProfile(
                                                      patient),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    patient.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        patient.consultationType
                                                                .contains(
                                                                    'Video')
                                                            ? Icons.videocam
                                                            : Icons.home_work,
                                                        size: 18,
                                                        color: patient
                                                                .consultationType
                                                                .contains(
                                                                    'Video')
                                                            ? grey600
                                                            : grey400,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        patient
                                                            .consultationType,
                                                        style: TextStyle(
                                                          color: grey600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Show patient CIN if available for debugging
                                                  if (patient
                                                      .patientCin.isNotEmpty)
                                                    Text(
                                                      'ID: ${patient.patientCin}',
                                                      style: TextStyle(
                                                        color: grey400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_isViewingPreviousAppointments)
                                            IconButton(
                                              icon: Icon(
                                                LucideIcons.fileText,
                                                color: grey600,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                // View medical record for this previous appointment
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Viewing medical record for ${patient.name}')),
                                                );
                                              },
                                            )
                                          else
                                            // Show more options button for current appointments
                                            IconButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: grey600,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showPatientOptionsMenu(
                                                      context, patient),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format date for display in previous appointments
  String _formatAppointmentDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
