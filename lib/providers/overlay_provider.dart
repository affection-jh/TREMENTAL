import 'package:flutter/material.dart';

class OverlayProvider extends ChangeNotifier {
  bool _isVisible = false;
  Widget? _overlay;

  bool get isVisible => _isVisible;
  Widget? get overlay => _overlay;

  void show([Widget? overlay]) {
    _overlay = overlay;
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    _overlay = null;
    notifyListeners();
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}
