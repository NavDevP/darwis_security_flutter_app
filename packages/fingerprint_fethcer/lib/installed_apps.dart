import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fingerprint/app_info.dart';
import 'dart:developer';

class InstalledApps {
  static const MethodChannel _channel = const MethodChannel('fingerprint');

  static Future<List<AppInfo>> getInstalledApps([
    bool excludeSystemApps = true,
    bool withIcon = false,
    String packageNamePrefix = "",
    bool withSha256 = false,
    bool withMd5 = false,
  ]) async {
    List<dynamic> apps = await _channel.invokeMethod(
      'getInstalledApps',
      {
        "exclude_system_apps": excludeSystemApps,
        "with_icon": withIcon,
        "package_name_prefix": packageNamePrefix,
        "with_sha256": withSha256,
        "with_md5": withMd5,
      },
    );
    List<AppInfo> appInfoList = apps.map((app) => AppInfo.create(app)).toList();
    appInfoList.sort((a, b) => a.name!.compareTo(b.name!));
    return appInfoList;
  }

  static Future<bool?> startApp(String packageName) async {
    return _channel.invokeMethod(
      "startApp",
      {"package_name": packageName},
    );
  }

  static openSettings(String packageName) {
    _channel.invokeMethod(
      "openSettings",
      {"package_name": packageName},
    );
  }

  static toast(String message, bool isShortLength) {
    _channel.invokeMethod(
      "toast",
      {
        "message": message,
        "short_length": isShortLength,
      },
    );
  }

  static Future<AppInfo> getAppInfo(String packageName) async {
    var app = await _channel.invokeMethod(
      "getAppInfo",
      {"package_name": packageName},
    );
    if (app == null) {
      throw ("App not found with provided package name $packageName");
    } else {
      return AppInfo.create(app);
    }
  }

  static Future<String> getAppFile(String packageName) async {
    var app = await _channel.invokeMethod(
      "getAppFile",
      {"package_name": packageName},
    );
    if (app == null) {
      throw ("App not found with provided package name $packageName");
    } else {
      return app;
    }
  }

  static Future<String> getSha(String packageName,String instanceType) async {
    var app = await _channel.invokeMethod(
      "getSha",
      {"package_name": packageName,"instance_type": instanceType},
    );
    if (app == null) {
      throw ("App not found with provided package name $packageName");
    } else {
      return app.toString();
    }
  }

  static Future<bool?> isSystemApp(String packageName) async {
    return _channel.invokeMethod(
      "isSystemApp",
      {"package_name": packageName},
    );
  }
}
