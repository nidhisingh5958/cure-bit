import 'dart:typed_data';
import 'package:CuraDocs/common/components/app_header.dart';
import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Scan QR',
      child: Scaffold(
        appBar: AppHeader(
          title: 'Scan QR Code',
          onBackPressed: () {
            context.goNamed(RouteConstants.home);
          },
        ),
        body: MobileScanner(
          controller: MobileScannerController(
            facing: CameraFacing.back,
            torchEnabled: false,
            detectionSpeed: DetectionSpeed.noDuplicates,
            returnImage: true,
          ),
          onDetect: (capture) {
            debugPrint("object detected");
            final List<Barcode> barcodes = capture.barcodes;
            final Uint8List? image = capture.image;
            for (final barcode in barcodes) {
              debugPrint('Barcode detected! ${barcode.rawValue}');
            }

            if (image != null) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                          barcodes.first.rawValue ?? 'No QR Code detected'),
                      content: Image(
                        image: MemoryImage(image),
                      ),
                    );
                  });
            }
          },
        ),
      ),
    );
  }
}
