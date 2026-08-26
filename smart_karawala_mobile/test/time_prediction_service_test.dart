import 'package:flutter_test/flutter_test.dart';
import 'package:smart_karawala_mobile/services/Drying/time_prediction_service.dart';

void main() {
  group('TimePredictionService', () {
    test('predictInitial calls the /api/predict/initial endpoint', () {
      expect(TimePredictionService.baseUrl, 'http://localhost:8003/api/predict');
      expect(TimePredictionService.predictInitial, isNotNull);
    });

    test('converts the displayed prediction to the same oven duration', () {
      expect(
        TimePredictionService.durationMinutesFromHours(19 / 60),
        19,
      );
    });

    test('rejects an invalid oven duration', () {
      expect(
        () => TimePredictionService.durationMinutesFromHours(0),
        throwsArgumentError,
      );
      expect(
        () => TimePredictionService.durationMinutesFromHours(double.nan),
        throwsArgumentError,
      );
    });
  });
}
