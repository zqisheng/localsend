import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/http_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/rust/api/http.dart';
import 'package:localsend_app/util/rust.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// Registers with a device when adding it as a favorite.
/// Tries both HTTP and HTTPS because remote devices may use a different
/// encryption setting than the local app.
Future<ResultWithPublicKeyRegisterResponseDto> registerDeviceForFavorite({
  required Ref ref,
  required String ip,
  required int port,
}) async {
  final payload = ref.read(deviceFullInfoProvider).toRegisterDto();
  final preferHttps = ref.read(settingsProvider).https;
  final protocols = preferHttps
      ? [ProtocolType.https, ProtocolType.http]
      : [ProtocolType.http, ProtocolType.https];

  Object? lastError;
  for (final protocol in protocols) {
    try {
      return await ref.read(httpProvider).v2.register(
        protocol: protocol,
        ip: ip,
        port: port,
        payload: payload,
      );
    } catch (e) {
      lastError = e;
    }
  }

  throw lastError ?? Exception('Failed to connect to device');
}