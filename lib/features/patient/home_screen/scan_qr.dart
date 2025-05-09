import 'package:flutter/material.dart';

class ScanQR extends StatelessWidget {
  const ScanQR({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Implement QR code scanning functionality here
          },
          child: const Text('Scan QR Code'),
        ),
      ),
    );
  }
}
