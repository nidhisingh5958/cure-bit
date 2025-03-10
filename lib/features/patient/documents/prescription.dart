import 'package:CuraDocs/components/colors.dart';
import 'package:CuraDocs/features/patient/documents/components/search.dart';
import 'package:flutter/material.dart';

class Prescriptions {
  final String diagnosis;
  final String date;
  final String doctor;

  Prescriptions({
    required this.date,
    required this.diagnosis,
    required this.doctor,
  });
}

class PrescriptionScreen extends StatelessWidget {
  final List<Prescriptions> prescriptionData;

  const PrescriptionScreen({required this.prescriptionData, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchFilter(),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color1,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Diagnosis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color1,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Doctor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of prescription
        Expanded(
          child: ListView.builder(
            itemCount: prescriptionData.length,
            itemBuilder: (context, index) {
              final record = prescriptionData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        record.date,
                        style: const TextStyle(
                          color: color1,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        record.diagnosis,
                        style: const TextStyle(
                          color: color1,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        record.doctor,
                        style: const TextStyle(
                          color: color1,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Sample prescription data
final List<Prescriptions> prescriptionData = [
  Prescriptions(
    date: '10 Feb 25',
    diagnosis: 'Fever Prescription',
    doctor: 'Dr. Vivek',
  ),
  Prescriptions(
    date: '5 Jan 25',
    diagnosis: 'Tooth Acne',
    doctor: 'Dr. Nandini',
  ),
  Prescriptions(
    date: '22 Nov 24',
    diagnosis: 'Skin Infection',
    doctor: 'Dr. Yashraj',
  ),
];
