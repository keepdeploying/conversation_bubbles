import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Takes note of the number of times the notifications permission has been
/// requested. If it exceeds 2, the user is redirected to the app settings.
int _requestCount = 0;

class NotificationsPermissionService with WidgetsBindingObserver {
  final _ctrl = StreamController<bool>.broadcast()..add(false);

  static final instance = NotificationsPermissionService._();

  NotificationsPermissionService._() {
    check();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      check();
    }
  }

  Stream<bool> get isGrantedStream => _ctrl.stream;

  Future<void> check() async {
    _ctrl.add((await Permission.notification.status).isGranted);
  }

  Future<void> request() async {
    if (_requestCount > 2) {
      await openAppSettings();
      return;
    }
    _requestCount++;
    await Permission.notification.request();
    await check();
  }
}
