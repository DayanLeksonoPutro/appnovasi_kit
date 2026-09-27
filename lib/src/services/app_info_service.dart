import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  const AppInfoService({
    this.appName = '',
    this.packageName = '',
    this.version = '',
    this.buildNumber = '',
  });

  factory AppInfoService.fromPackageInfo(PackageInfo info) => AppInfoService(
    appName: info.appName,
    packageName: info.packageName,
    version: info.version,
    buildNumber: info.buildNumber,
  );

  static Future<AppInfoService> load() async {
    try {
      return AppInfoService.fromPackageInfo(await PackageInfo.fromPlatform());
    } catch (_) {
      return const AppInfoService();
    }
  }

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  bool get hasVersion => version.isNotEmpty;

  String get versionLabel =>
      buildNumber.isEmpty ? 'v$version' : 'v$version ($buildNumber)';
}
