import 'package:CureBit/common/components/app_header.dart';
import 'package:flutter/material.dart';

class DoctorQR extends StatefulWidget {
  const DoctorQR({super.key});

  @override
  State<DoctorQR> createState() => _DoctorQRState();
}

class _DoctorQRState extends State<DoctorQR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Profile QR Code ',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Center(
        child: Image(image: AssetImage('assets/images/qr_code.png')),
      ),
    );
  }
}
