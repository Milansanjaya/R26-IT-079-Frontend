class WeightFormatter {
  /// Formats a weight in kilograms to a readable display string.
  /// If the weight is less than 1 kg (e.g. 0.095 kg), it displays in grams (e.g. "95 g").
  /// If 1 kg or more, it displays in kilograms (e.g. "1.5 kg").
  static String format(double weightInKg) {
    if (weightInKg <= 0) return "0 g";

    if (weightInKg < 1.0) {
      final double grams = weightInKg * 1000;
      if ((grams - grams.roundToDouble()).abs() < 0.01) {
        return "${grams.round()} g";
      }
      return "${grams.toStringAsFixed(1)} g";
    } else {
      if ((weightInKg - weightInKg.roundToDouble()).abs() < 0.01) {
        return "${weightInKg.round()} kg";
      }
      return "${weightInKg.toStringAsFixed(2)} kg";
    }
  }
}
