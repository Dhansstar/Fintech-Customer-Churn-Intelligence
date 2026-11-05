import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  // Data Feature Importances dari Notebook (Tanpa karakter > sebelum [)
  final featureImportances = [
    {'index': 0, 'name': 'Age', 'score': 0.43},
    {'index': 1, 'name': 'NumOfProducts', 'score': 0.36},
    {'index': 2, 'name': 'IsActiveMember', 'score': 0.10},
    {'index': 3, 'name': 'Balance', 'score': 0.08},
    {'index': 4, 'name': 'EstimatedSalary', 'score': 0.03},
    {'index': 5, 'name': 'CreditScore', 'score': 0.01},
    {'index': 6, 'name': 'Tenure', 'score': 0.005},
  ].obs;

  // Data Confusion Matrix Reactive
  final trueRetained = 1531.obs;
  final falseChurn = 62.obs;
  final falseRetain = 220.obs;
  final trueChurn = 187.obs;
}