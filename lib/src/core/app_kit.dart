import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/ad_service.dart';
import '../services/storage_service.dart';
import 'app_config.dart';

class AppKit {
  AppKit._();

  static late final AppConfig config;
  static late final StorageService storage;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize(AppConfig config) async {
    WidgetsFlutterBinding.ensureInitialized();
    AppKit.config = config;
    await Hive.initFlutter();
    storage = StorageService();
    await storage.init();
    await AdService.initialize(config);
    _initialized = true;
  }
}
