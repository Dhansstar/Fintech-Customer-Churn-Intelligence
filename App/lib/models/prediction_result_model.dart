class PredictionResultModel {
  final bool isChurn;
  final double churnProbability;
  final String riskLevel;

  PredictionResultModel({
    required this.isChurn,
    required this.churnProbability,
    required this.riskLevel,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      isChurn: json['is_churn'] ?? false,
      churnProbability: (json['churn_probability'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] ?? 'UNKNOWN',
    );
  }
}