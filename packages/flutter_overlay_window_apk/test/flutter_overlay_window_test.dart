import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_overlay_window_apk/flutter_overlay_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterOverlayWindow', () {
    test('closeOverlay should close the overlay', () async {
      await FlutterOverlayApkWindow.closeOverlay();
      expect(await FlutterOverlayApkWindow.isActive(), isFalse);
    });

    if (defaultTargetPlatform == TargetPlatform.android) {
      test('isPermissionGranted should return a boolean', () async {
        final result = await FlutterOverlayApkWindow.isPermissionGranted();
        expect(result, isA<bool>());
      });
    }
    test('requestPermission should return a boolean', () async {
      final result = await FlutterOverlayApkWindow.requestPermission();
      expect(result, isA<bool>());
    });
  });
}
