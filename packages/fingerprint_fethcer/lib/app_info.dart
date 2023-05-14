import 'dart:typed_data';

class AppInfo {
  String? name;
  Uint8List? icon;
  String? packageName;
  String? versionName;
  int? versionCode;
  String? sha256;
  String? md5;

  AppInfo(
    this.name,
    this.icon,
    this.packageName,
    this.versionName,
    this.versionCode,
    this.sha256,
    this.md5,
  );

  factory AppInfo.create(dynamic data) {
    return AppInfo(
      data["name"],
      data["icon"],
      data["package_name"],
      data["version_name"],
      data["version_code"],
      data["sha256"],
      data["md5"],
    );
  }

  String getVersionInfo() {
    return "$versionName ($versionCode)";
  }
}
