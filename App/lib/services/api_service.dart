import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/churn_stats_model.dart';
import '../models/prediction_result_model.dart';

class ApiService {
  // IP 10.0.2.2 untuk Android Emulator, ubah ke localhost jika me-run di Chrome
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  static Future<ChurnStatsModel> fetchChurnStats() async {
    final response = await http.get(Uri.parse('$baseUrl/churn/stats'));
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return ChurnStatsModel.fromJson(jsonBody['data']);
    } else {
      throw Exception('Gagal memuat statistik Data Warehouse');
    }
  }

  // Kirim data nasabah baru untuk diprediksi oleh best_churn_pipeline.pkl
  static Future<PredictionResultModel> predictChurn(Map<String, dynamic> customerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/churn/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customerData),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return PredictionResultModel.fromJson(jsonBody['data']);
    } else {
      throw Exception('Gagal mendapatkan prediksi dari server ML');
    }
  }
}