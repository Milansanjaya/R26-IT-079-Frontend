import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _cloudBaseUrl = 'https://api.smartkarawala.me';
  static const String _cloudVsUrl = 'https://vs.smartkarawala.me';

  /// True ONLY when explicitly running as a local Web debug session in Chrome/browser
  static bool get isLocalWeb =>
      kIsWeb &&
      (Uri.base.host == 'localhost' ||
          Uri.base.host == '127.0.0.1' ||
          Uri.base.host.startsWith('192.168.') ||
          Uri.base.host.startsWith('10.'));

  /// Production mode applies to:
  /// 1. Any mobile device or emulator (Android APK, iOS app)
  /// 2. Any hosted production web build (e.g. app.smartkarawala.me)
  static bool get isProduction => !isLocalWeb;

  // Backward compatibility alias
  static bool get isProductionWeb => isProduction;

  /// Unified Backend Gateway Host: https://api.smartkarawala.me
  static String get apiGatewayUrl {
    if (isProduction) {
      return _cloudBaseUrl;
    }
    return 'http://127.0.0.1:8000';
  }

  /// Auth Service URL
  static String get authBaseUrl {
    if (isProduction) {
      return _cloudBaseUrl;
    }
    return 'http://127.0.0.1:8000';
  }

  /// Batches, Salting & Waste Service URL
  static String get batchesBaseUrl {
    if (isProduction) {
      return '$_cloudBaseUrl/api/batches';
    }
    return 'http://localhost:8001/api/batches';
  }

  /// Salting & Waste Base Root URL
  static String get wasteBaseUrl {
    if (isProduction) {
      return _cloudBaseUrl;
    }
    return 'http://localhost:8001';
  }

  /// IoT Environment Monitoring Service URL
  static String get iotBaseUrl {
    if (isProduction) {
      return _cloudBaseUrl;
    }
    return 'http://127.0.0.1:8002';
  }

  /// Time & Spoilage Prediction Service URL
  static String get predictBaseUrl {
    if (isProduction) {
      return '$_cloudBaseUrl/api/predict';
    }
    return 'http://localhost:8003/api/predict';
  }

  /// Active Drying Process URL
  static String get dryingBaseUrl {
    if (isProduction) {
      return '$_cloudBaseUrl/api/drying';
    }
    return 'http://localhost:8003/api/drying';
  }

  /// Verification Station Next.js Camera & Vision Service URL
  static String get verificationStationUrl {
    if (isProduction) {
      return _cloudVsUrl;
    }
    return 'http://localhost:3000';
  }
}
