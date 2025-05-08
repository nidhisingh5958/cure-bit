class Patient {
  final String name;
  final String patientId;
  final String location;
  final String country;
  final String status;
  final String condition;
  final double lastPayment;
  final String nextAppointment;
  late final bool isSelected;

  Patient({
    required this.name,
    required this.patientId,
    required this.location,
    required this.country,
    required this.status,
    required this.condition,
    required this.lastPayment,
    required this.nextAppointment,
    this.isSelected = false,
  });
}

// Sample patient data
final List<Patient> patientData = [
  Patient(
    name: 'Alex Allan',
    patientId: 'PT-10542',
    location: 'São Paulo',
    country: 'BR',
    status: 'Active',
    condition: 'Stable',
    lastPayment: 2100.00,
    nextAppointment: 'May 15, 2025',
  ),
  Patient(
    name: 'Alex Thompson',
    patientId: 'PT-22871',
    location: 'San Francisco',
    country: 'US',
    status: 'Inactive',
    condition: 'Discharged',
    lastPayment: 1750.00,
    nextAppointment: 'None',
  ),
  Patient(
    name: 'Anna Visconti',
    patientId: 'PT-31649',
    location: 'Rome',
    country: 'IT',
    status: 'Active',
    condition: 'Improving',
    lastPayment: 0.00,
    nextAppointment: 'May 10, 2025',
  ),
  Patient(
    name: 'Astrid Andersen',
    patientId: 'PT-45298',
    location: 'Oslo',
    country: 'NO',
    status: 'Inactive',
    condition: 'Discharged',
    lastPayment: 1100.00,
    nextAppointment: 'None',
  ),
  Patient(
    name: 'Cheng Wei',
    patientId: 'PT-53781',
    location: 'Shanghai',
    country: 'CN',
    status: 'Critical',
    condition: 'Critical',
    lastPayment: 2700.00,
    nextAppointment: 'May 9, 2025',
  ),
  Patient(
    name: 'David Kim',
    patientId: 'PT-65921',
    location: 'Paris',
    country: 'FR',
    status: 'Active',
    condition: 'Monitoring',
    lastPayment: 890.00,
    nextAppointment: 'May 12, 2025',
  ),
  Patient(
    name: 'Diego Mendoza',
    patientId: 'PT-72034',
    location: 'Mexico City',
    country: 'MX',
    status: 'Active',
    condition: 'Stable',
    lastPayment: 1800.00,
    nextAppointment: 'May 18, 2025',
  ),
  Patient(
    name: 'Emma Laurent',
    patientId: 'PT-83647',
    location: 'Berlin',
    country: 'DE',
    status: 'Active',
    condition: 'Improving',
    lastPayment: 1200.00,
    nextAppointment: 'May 14, 2025',
  ),
  Patient(
    name: 'Eva Kowalski',
    patientId: 'PT-91572',
    location: 'Seoul',
    country: 'KR',
    status: 'Active',
    condition: 'Stable',
    lastPayment: 920.00,
    nextAppointment: 'May 11, 2025',
    isSelected: true,
  ),
  Patient(
    name: 'Fatima Al-Sayed',
    patientId: 'PT-10483',
    location: 'Cairo',
    country: 'EG',
    status: 'Active',
    condition: 'Monitoring',
    lastPayment: 1950.00,
    nextAppointment: 'May 16, 2025',
  ),
];
