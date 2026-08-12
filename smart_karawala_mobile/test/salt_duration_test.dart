import 'package:flutter_test/flutter_test.dart';
import 'package:smart_karawala_mobile/services/Salt/salt_service.dart';

void main() {
  group('Rule-based Salting Duration Calculation Tests', () {
    test('Cleaned weight between 0 - 100 kg returns 12 hours / "12 Hours"', () {
      expect(SaltService.getRecommendedDuration(0.0), "12 Hours");
      expect(SaltService.getRecommendedDuration(85.0), "12 Hours");
      expect(SaltService.getRecommendedDuration(100.0), "12 Hours");
      expect(SaltService.calculateRecommendedDuration(85.0), 12);
    });

    test('Cleaned weight between 101 - 200 kg returns 24 hours / "24 Hours"', () {
      expect(SaltService.getRecommendedDuration(100.1), "24 Hours");
      expect(SaltService.getRecommendedDuration(150.0), "24 Hours");
      expect(SaltService.getRecommendedDuration(200.0), "24 Hours");
      expect(SaltService.calculateRecommendedDuration(150.0), 24);
    });

    test('Cleaned weight between 201 - 300 kg returns 48 hours / "48 Hours"', () {
      expect(SaltService.getRecommendedDuration(200.1), "48 Hours");
      expect(SaltService.getRecommendedDuration(250.0), "48 Hours");
      expect(SaltService.getRecommendedDuration(300.0), "48 Hours");
      expect(SaltService.calculateRecommendedDuration(250.0), 48);
    });

    test('Cleaned weight above 300 kg returns 72 hours / "72 Hours"', () {
      expect(SaltService.getRecommendedDuration(300.1), "72 Hours");
      expect(SaltService.getRecommendedDuration(400.0), "72 Hours");
      expect(SaltService.getRecommendedDuration(1000.0), "72 Hours");
      expect(SaltService.calculateRecommendedDuration(400.0), 72);
    });
  });
}
