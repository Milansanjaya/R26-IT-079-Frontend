import 'package:flutter/foundation.dart';

class AppConfig {
  static bool get isProductionWeb =>
      kIsWeb &&
      (Uri.base.host.contains('smartkarawala.me') ||
          Uri.base.host.contains('194.163.168.1'));

  /// Unified Backend Gateway Host: https://api.smartkarawala.me
  static String get apiGatewayUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Auth Service URL
  static String get authBaseUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Batches, Salting & Waste Service URL
  static String get batchesBaseUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me/api/batches';
    }
    return 'http://localhost:8001/api/batches';
  }

  /// Salting & Waste Base Root URL
  static String get wasteBaseUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me';
    }
    return 'http://localhost:8001';
  }

  /// IoT Environment Monitoring Service URL
  static String get iotBaseUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me';
    }
    return 'http://127.0.0.1:8002';
  }

  /// Time & Spoilage Prediction Service URL
  static String get predictBaseUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me/api/predict';
    }
    return 'http://localhost:8003/api/predict';
  }

  /// Active Drying Process URL
  static String get dryingBaseUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://api.smartkarawala.me/api/drying';
    }
    return 'http://localhost:8003/api/drying';
  }

  /// Verification Station Next.js Camera & Vision Service URL
  static String get verificationStationUrl {
    if (isProductionWeb) {
      return '${Uri.base.scheme}://vs.smartkarawala.me';
    }
    return 'http://localhost:3000';
  }
}
