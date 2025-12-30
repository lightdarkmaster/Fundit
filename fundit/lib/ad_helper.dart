import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9713545991855839~1521787968'; // Test Ad Unit ID for Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test Ad Unit ID for iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
