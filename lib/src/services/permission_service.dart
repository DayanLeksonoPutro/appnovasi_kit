import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService();

  static const _grantedStatuses = {
    PermissionStatus.granted,
    PermissionStatus.limited,
    PermissionStatus.provisional,
  };

  bool isAllowed(PermissionStatus status) => _grantedStatuses.contains(status);

  Future<PermissionStatus> status(Permission permission) => permission.status;

  Future<bool> isGranted(Permission permission) async =>
      isAllowed(await permission.status);

  Future<PermissionStatus> request(Permission permission) =>
      permission.request();

  Future<Map<Permission, PermissionStatus>> requestAll(
    List<Permission> permissions,
  ) => permissions.request();

  Future<bool> ensure(Permission permission) async {
    final current = await permission.status;
    if (isAllowed(current)) return true;

    final result = await permission.request();
    if (isAllowed(result)) return true;

    if (result.isPermanentlyDenied || result.isRestricted) {
      await openSettings();
    }
    return false;
  }

  Future<bool> isServiceEnabled(PermissionWithService permission) async =>
      (await permission.serviceStatus).isEnabled;

  Future<bool> shouldShowRationale(Permission permission) =>
      permission.shouldShowRequestRationale;

  Future<bool> openSettings() => openAppSettings();
}
