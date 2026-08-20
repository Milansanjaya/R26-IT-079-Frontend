import 'package:flutter_test/flutter_test.dart';
import 'package:smart_karawala_mobile/services/Drying/time_prediction_service.dart';

void main() {
  group('TimePredictionService', () {
    test('predictInitial calls the /api/predict/initial endpoint', () {
      expect(TimePredictionService.baseUrl, 'http://localhost:8003/api/predict');
      expect(TimePredictionService.predictInitial, isNotNull);
    });
  });
}
