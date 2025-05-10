import 'package:CuraDocs/components/app_header.dart';
import 'package:flutter/material.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
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
