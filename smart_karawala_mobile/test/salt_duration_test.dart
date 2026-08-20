import 'package:flutter_test/flutter_test.dart';
import 'package:smart_karawala_mobile/services/Salt/salt_service.dart';

void main() {
  group('Rule-based Salting Duration Calculation Tests', () {
    test('Salaya (small fish) with 0.2 kg returns 4 Hours', () {
      expect(SaltService.getRecommendedDuration(0.2, "Salaya"), "4 Hours");
      expect(SaltService.calculateRecommendedDuration(0.2, "Salaya"), 4);
    });

    test('Balaya (medium fish) with 0.2 kg returns 6 Hours', () {
      expect(SaltService.getRecommendedDuration(0.2, "Balaya"), "6 Hours");
      expect(SaltService.calculateRecommendedDuration(0.2, "Balaya"), 6);
    });

    test('Thalapath (thick fish) with 0.2 kg returns 8 Hours', () {
      expect(SaltService.getRecommendedDuration(0.2, "Thalapath"), "8 Hours");
      expect(SaltService.calculateRecommendedDuration(0.2, "Thalapath"), 8);
    });
  });
}
