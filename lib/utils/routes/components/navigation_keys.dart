// navigator_keys.dart
import 'package:flutter/material.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Doctor keys
final doctorHomeNavigatorKey = GlobalKey<NavigatorState>();
final doctorChatNavigatorKey = GlobalKey<NavigatorState>();
final doctorProfileNavigatorKey = GlobalKey<NavigatorState>();
final doctorPatientsNavigatorKey = GlobalKey<NavigatorState>();

// Patient keys

final homeNavigatorKey = GlobalKey<NavigatorState>();
final chatNavigatorKey = GlobalKey<NavigatorState>();
final documentsNavigatorKey = GlobalKey<NavigatorState>();
final profileNavigatorKey = GlobalKey<NavigatorState>();
