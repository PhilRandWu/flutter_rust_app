import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

const String appVersion = '1.0.0';

String? _cachedUserAgent;

Future<String> getUserAgent() async {
  if (_cachedUserAgent != null) {
    return _cachedUserAgent!;
  }

  try {
    final deviceInfo = DeviceInfoPlugin();
    final Map<String, dynamic> userAgentData = {
      'appVersion': appVersion,
      'os': _getOsName(),
      'osVersion': await _getOsVersion(deviceInfo),
      'isMobile': _isMobilePlatform(),
      'platformType': _getPlatformType(),
    };

    await _fillPlatformSpecificInfo(deviceInfo, userAgentData);

    _cachedUserAgent = _buildUserAgentString(userAgentData);
    return _cachedUserAgent!;
  } catch (e, stackTrace) {
    debugPrint('获取UserAgent失败：$e，堆栈：$stackTrace');
    final fallbackUA =
        'appVersion=$appVersion; os=${_getOsName()}; isMobile=${_isMobilePlatform()}; error=fetch_failed';
    _cachedUserAgent = fallbackUA;
    return fallbackUA;
  }
}

String _getOsName() {
  if (kIsWeb) return 'web';
  return Platform.operatingSystem;
}

bool _isMobilePlatform() {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

String _getPlatformType() {
  if (kIsWeb) return 'browser';
  if (Platform.isAndroid || Platform.isIOS) return 'mobile';
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return 'desktop';
  }
  return 'unknown';
}

Future<String> _getOsVersion(DeviceInfoPlugin deviceInfo) async {
  if (kIsWeb) return 'unknown';

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return macInfo.osRelease;
    } else if (Platform.isWindows) {
      final winInfo = await deviceInfo.windowsInfo;
      return winInfo.displayVersion;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.prettyName;
    }
  } catch (e) {
    debugPrint('获取系统版本失败：$e');
  }

  return 'unknown';
}

Future<void> _fillPlatformSpecificInfo(
  DeviceInfoPlugin deviceInfo,
  Map<String, dynamic> userAgentData,
) async {
  if (kIsWeb) {
    final webInfo = await deviceInfo.webBrowserInfo;
    userAgentData['browser'] = webInfo.browserName.name.toLowerCase();
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    userAgentData['model'] = androidInfo.model;
    userAgentData['manufacturer'] = androidInfo.manufacturer;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    userAgentData['model'] = iosInfo.model;
    userAgentData['deviceId'] = iosInfo.identifierForVendor;
  } else if (Platform.isMacOS) {
    final macInfo = await deviceInfo.macOsInfo;
    userAgentData['model'] = macInfo.model;
  } else if (Platform.isWindows) {
    final winInfo = await deviceInfo.windowsInfo;
    userAgentData['model'] = winInfo.computerName;
  } else if (Platform.isLinux) {
    final linuxInfo = await deviceInfo.linuxInfo;
    userAgentData['model'] = linuxInfo.prettyName;
  }
}

String _buildUserAgentString(Map<String, dynamic> data) {
  final validEntries = data.entries.where(
    (entry) => entry.value != null && entry.value.toString().isNotEmpty,
  );

  return validEntries
      .map(
        (entry) =>
            '${entry.key}=${entry.value.toString().replaceAll(';', '_')}',
      )
      .join('; ');
}

void clearUserAgentCache() {
  _cachedUserAgent = null;
}
