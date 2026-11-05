import 'package:get/get.dart';
import '../models/churn_stats_model.dart';
import '../models/prediction_result_model.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var isPredicting = false.obs;

  // Fix Rxn type definition
  var churnStats = Rxn<ChurnStatsModel>();
  var predictionResult = Rxn<PredictionResultModel>();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    try {
      isLoading(true);
      var stats = await ApiService.fetchChurnStats();
      churnStats.value = stats;
    } catch (e) {
      Get.snackbar('Error DW', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void runPrediction(Map<String, dynamic> customerPayload) async {
    try {
      isPredicting(true);
      var result = await ApiService.predictChurn(customerPayload);
      predictionResult.value = result;
    } catch (e) {
      Get.snackbar('Error Prediksi ML', e.toString());
    } finally {
      isPredicting(false);
    }
  }
}