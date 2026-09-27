import 'package:flutter/foundation.dart';

import '../../services/storage_service.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._storage)
    : _completed = _storage.read<bool>(_key) ?? false;

  static const String _key = 'onboarding_completed';

  final StorageService _storage;
  bool _completed;

  bool get isCompleted => _completed;

  Future<void> complete() async {
    if (_completed) return;
    _completed = true;
    await _storage.write(_key, true);
    notifyListeners();
  }

  Future<void> reset() async {
    if (!_completed) return;
    _completed = false;
    await _storage.delete(_key);
    notifyListeners();
  }
}
