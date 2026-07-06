import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

const _methodChannel = MethodChannel('org.localsend.localsend_app/localsend');
final _logger = Logger('KeepAlive');

/// Starts or stops the Android foreground keep-alive service.
Future<void> syncBackgroundKeepAlive(bool enabled) async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    if (enabled) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        _logger.warning('Notification permission not granted, keep-alive may not work');
      }
      await _methodChannel.invokeMethod('startKeepAlive');
      await _methodChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    } else {
      await _methodChannel.invokeMethod('stopKeepAlive');
    }
  } catch (e, stackTrace) {
    _logger.warning('Failed to sync background keep-alive', e, stackTrace);
  }
}

Future<bool> isKeepAliveRunning() async {
  if (!Platform.isAndroid) {
    return false;
  }

  try {
    return await _methodChannel.invokeMethod<bool>('isKeepAliveRunning') ?? false;
  } catch (_) {
    return false;
  }
}

/// Requests to add the LocalSend quick settings tile (Android 13+).
Future<bool> requestAddQuickTile() async {
  if (!Platform.isAndroid) {
    return false;
  }

  try {
    return await _methodChannel.invokeMethod<bool>('requestAddQuickTile') ?? false;
  } catch (e, stackTrace) {
    _logger.warning('Failed to request quick settings tile', e, stackTrace);
    return false;
  }
}