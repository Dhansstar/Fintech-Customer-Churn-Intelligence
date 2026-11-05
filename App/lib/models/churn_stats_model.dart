class ChurnStatsModel {
  final int totalCustomers;
  final int totalChurned;
  final double churnRate;
  final double avgBalance;

  ChurnStatsModel({
    required this.totalCustomers,
    required this.totalChurned,
    required this.churnRate,
    required this.avgBalance,
  });

  factory ChurnStatsModel.fromJson(Map<String, dynamic> json) {
    return ChurnStatsModel(
      totalCustomers: _parseInt(json['totalCustomers'] ?? json['total_customers']),
      totalChurned: _parseInt(json['totalChurned'] ?? json['total_churned']),
      churnRate: _parseDouble(json['churnRate'] ?? json['churn_rate']),
      avgBalance: _parseDouble(json['avgBalance'] ?? json['avg_balance']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}