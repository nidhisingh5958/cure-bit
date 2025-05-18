import 'package:flutter/services.dart';

void setStatusBarColor(Color color) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: color,
    statusBarBrightness:
        color.computeLuminance() < 0.5 ? Brightness.light : Brightness.dark,
  ));
}
