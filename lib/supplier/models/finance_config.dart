class FinanceConfig {
  final double ppks;
  final double ppkm;
  final double ppkl;
  final double minCharge;
  final double cashCc;
  final double percentage;

  FinanceConfig({
    required this.ppks,
    required this.ppkm,
    required this.ppkl,
    required this.minCharge,
    required this.cashCc,
    required this.percentage,
  });

  factory FinanceConfig.fromJson(Map<String, dynamic> json) {
    return FinanceConfig(
      ppks: double.tryParse(json['PPKS']?.toString() ?? '0') ?? 0.0,
      ppkm: double.tryParse(json['PPKM']?.toString() ?? '0') ?? 0.0,
      ppkl: double.tryParse(json['PPKL']?.toString() ?? '0') ?? 0.0,
      minCharge: double.tryParse(json['min_charge']?.toString() ?? '0') ?? 0.0,
      cashCc: double.tryParse(json['cash_cc']?.toString() ?? '0') ?? 0.0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
    );
  }

  double calculateCost({
    required String size,
    required String paymentMethod,
  }) {
    double baseCost = 0.0;
    if (size == "small") {
      baseCost = ppks;
    } else if (size == "medium") {
      baseCost = ppkm;
    } else if (size == "large") {
      baseCost = ppkl;
    }

    if (baseCost < minCharge) {
      baseCost = minCharge;
    }

    if (paymentMethod == "cash") {
      baseCost = baseCost * cashCc;
    }

    return baseCost;
  }

  double calculateCommission(double cost) {
    return (percentage / 100) * cost;
  }
}
