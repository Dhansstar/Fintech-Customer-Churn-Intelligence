import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class PredictFormView extends StatefulWidget {
  @override
  _PredictFormViewState createState() => _PredictFormViewState();
}

class _PredictFormViewState extends State<PredictFormView> {
  final DashboardController controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();

  final _creditScoreController = TextEditingController(text: "650");
  final _ageController = TextEditingController(text: "42");
  final _tenureController = TextEditingController(text: "5");
  final _balanceController = TextEditingController(text: "75000");
  final _salaryController = TextEditingController(text: "50000");

  String _geography = 'France';
  String _gender = 'Female';
  int _numOfProducts = 1;
  int _hasCrCard = 1;
  int _isActiveMember = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inference Engine - ML Prediction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demografi & Kredit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _geography,
                      decoration: InputDecoration(labelText: 'Geography', border: OutlineInputBorder()),
                      items: ['France', 'Germany', 'Spain'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _geography = v!),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                      items: ['Male', 'Female'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Umur', border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _creditScoreController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Credit Score', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Text('Profil Finansial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
              SizedBox(height: 10),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Balance / Saldo (\$) ', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Estimated Salary (\$) ', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _numOfProducts,
                      decoration: InputDecoration(labelText: 'Num Of Products', border: OutlineInputBorder()),
                      items: [1, 2, 3, 4].map((v) => DropdownMenuItem(value: v, child: Text('$v Produk'))).toList(),
                      onChanged: (v) => setState(() => _numOfProducts = v!),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _tenureController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Tenure (Tahun)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SwitchListTile(
                title: Text('Punya Kartu Kredit?'),
                value: _hasCrCard == 1,
                onChanged: (v) => setState(() => _hasCrCard = v ? 1 : 0),
              ),
              SwitchListTile(
                title: Text('Nasabah Aktif?'),
                value: _isActiveMember == 1,
                onChanged: (v) => setState(() => _isActiveMember = v ? 1 : 0),
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(Icons.psychology, color: Colors.white),
                label: Text('PREDIKSI ML (.PKL)', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    double balance = double.parse(_balanceController.text);
                    double salary = double.parse(_salaryController.text);
                    double ratio = salary > 0 ? double.parse((balance / salary).toStringAsFixed(4)) : 0.0;

                    Map<String, dynamic> payload = {
                      "CreditScore": int.parse(_creditScoreController.text),
                      "Geography": _geography,
                      "Gender": _gender,
                      "Age": int.parse(_ageController.text),
                      "Tenure": int.parse(_tenureController.text),
                      "Balance": balance,
                      "NumOfProducts": _numOfProducts,
                      "HasCrCard": _hasCrCard,
                      "IsActiveMember": _isActiveMember,
                      "EstimatedSalary": salary,
                      "Balance_Salary_Ratio": ratio,
                      "USD_TO_IDR": 15800.0
                    };

                    controller.runPrediction(payload);
                  }
                },
              ),

              SizedBox(height: 20),
              Obx(() {
                if (controller.isPredicting.value) {
                  return Center(child: CircularProgressIndicator());
                }
                final res = controller.predictionResult.value;
                if (res == null) return SizedBox.shrink();

                bool isHighRisk = res.riskLevel == 'HIGH RISK';

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHighRisk ? Colors.red.shade50 : Colors.green.shade50,
                    border: Border.all(color: isHighRisk ? Colors.red : Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('HASIL INFERENCE MODEL (.PKL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status Risiko:', style: TextStyle(fontSize: 16)),
                          Chip(
                            label: Text(res.riskLevel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: isHighRisk ? Colors.red : Colors.green,
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Probabilitas Churn: ${res.churnProbability}%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          isHighRisk
                              ? "💡 Rekomendasi Retensi: Nasabah berisiko tinggi Churn! Berikan penawaran bebas biaya admin atau undang ke program loyalty."
                              : "✅ Rekomendasi Retensi: Nasabah berisiko rendah. Pertahankan transaksi reguler.",
                          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}