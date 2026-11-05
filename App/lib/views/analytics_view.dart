import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends StatelessWidget {
  final AnalyticsController controller = Get.put(AnalyticsController());

  AnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildConfusionMatrixSection(),
            const SizedBox(height: 20),
            _buildFeatureImportanceSection(),
            const SizedBox(height: 20),
            _buildRocAucSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- 1. EXECUTIVE HEADER ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics_rounded, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Model Performance & Evaluation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Decision Tree Pipeline (best_churn_pipeline.pkl)',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. CONFUSION MATRIX HEATMAP ---
  Widget _buildConfusionMatrixSection() {
    // Pengganti Colors.slate900 menggunakan Color(0xFF0F172A)
    const Color slate900Color = Color(0xFF0F172A);

    return _buildCardWrapper(
      title: 'Confusion Matrix (Tuned Model)',
      subtitle: 'Evaluasi akurasi prediksi nasabah Churn vs Retained',
      child: Column(
        children: [
          const SizedBox(height: 12),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildHeatmapCell(
                  'True Retained (TN)',
                  '${controller.trueRetained.value}',
                  const Color(0xFF1E3A8A),
                  'Akurat memprediksi nasabah bertahan',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeatmapCell(
                  'False Churn (FP)',
                  '${controller.falseChurn.value}',
                  const Color(0xFFDBEAFE),
                  'Salah tebak nasabah bertahan jadi churn',
                  textColor: slate900Color, // FIX: Menggunakan Hex slate 900
                ),
              ),
            ],
          )),
          const SizedBox(height: 10),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildHeatmapCell(
                  'False Retain (FN)',
                  '${controller.falseRetain.value}',
                  const Color(0xFF93C5FD),
                  'Lolos! Nasabah churn dikira bertahan',
                  textColor: slate900Color, // FIX: Menggunakan Hex slate 900
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeatmapCell(
                  'True Churn (TP)',
                  '${controller.trueChurn.value}',
                  const Color(0xFF2563EB),
                  'Akurat mendeteksi nasabah Churn',
                ),
              ),
            ],
          )),
          const SizedBox(height: 16),
          _buildInsightBox('Model berhasil memprediksi nasabah bertransaksi dan mendeteksi nasabah berpotensi Churn secara presisi.'),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(String label, String value, Color color, String tooltipMsg, {Color textColor = Colors.white}) {
    return Tooltip(
      message: tooltipMsg,
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.85), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // --- 3. FEATURE IMPORTANCES BAR CHART ---
  Widget _buildFeatureImportanceSection() {
    return _buildCardWrapper(
      title: 'Top Feature Importances',
      subtitle: 'Fitur paling mendominasi pengaruh Churn nasabah',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: Obx(() => BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 0.5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final feature = controller.featureImportances[groupIndex];
                      return BarTooltipItem(
                        '${feature['name']}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        children: [
                          TextSpan(
                            text: '${(rod.toY * 100).toStringAsFixed(1)}% Influence',
                            style: const TextStyle(color: Colors.tealAccent, fontSize: 11),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < controller.featureImportances.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '$idx',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 0.1),
                barGroups: controller.featureImportances.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value['score'] as num).toDouble(),
                        gradient: const LinearGradient(
                          colors: [Colors.tealAccent, Colors.teal],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
              ),
            )),
          ),
          const SizedBox(height: 16),
          _buildInsightBox('Usia (Index 0: Age) & Jumlah Produk (Index 1: NumOfProducts) menyumbang >78% keputusan nasabah untuk Churn.'),
        ],
      ),
    );
  }

  // --- 4. ROC-AUC LINE CHART ---
  Widget _buildRocAucSection() {
    return _buildCardWrapper(
      title: 'Kurva ROC-AUC Comparison',
      subtitle: 'Perbandingan performa model sebelum & sesudah tuning',
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 1,
                minY: 0,
                maxY: 1,
                lineTouchData: LineTouchData(enabled: true),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade200)),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 0), FlSpot(0.05, 0.3), FlSpot(0.1, 0.5), FlSpot(0.2, 0.7), FlSpot(0.4, 0.85), FlSpot(0.6, 0.93), FlSpot(1, 1)],
                    isCurved: true,
                    color: Colors.amber.shade700,
                    barWidth: 2,
                    dashArray: [4, 4],
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 0), FlSpot(0.04, 0.32), FlSpot(0.08, 0.48), FlSpot(0.18, 0.72), FlSpot(0.35, 0.84), FlSpot(0.55, 0.94), FlSpot(1, 1)],
                    isCurved: true,
                    color: Colors.green.shade600,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 0), FlSpot(1, 1)],
                    color: Colors.grey.shade400,
                    barWidth: 1.5,
                    dashArray: [3, 3],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Tuned (0.8463)', Colors.green.shade600),
              _buildLegendItem('Baseline (0.8459)', Colors.amber.shade700),
              _buildLegendItem('Random (0.50)', Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGET HELPERS ---
  Widget _buildCardWrapper({required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          child,
        ],
      ),
    );
  }

  Widget _buildInsightBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
      ],
    );
  }
}