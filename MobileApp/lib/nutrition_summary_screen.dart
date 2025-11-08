
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class NutritionSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> nutritionData;
  final String summary;

  const NutritionSummaryScreen({super.key, required this.nutritionData, required this.summary});

  double _parseValue(String? value) {
    if (value == null) return 0;
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final protein = _parseValue(nutritionData['protein']);
    final carbs = _parseValue(nutritionData['carbohydrates']);
    final fats = _parseValue(nutritionData['fats']);
    final total = protein + carbs + fats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Summary'),
        backgroundColor: const Color(0xFF3A1C71),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A1C71), Color(0xFF6F1B7A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Summary Card
                Card(
                  color: const Color(0xFF2C125A),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(summary, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Macronutrient Breakdown Card
                Card(
                  color: const Color(0xFF2C125A),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Macronutrient Breakdown', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: total > 0
                                  ? [
                                      PieChartSectionData(color: Colors.green, value: protein, title: '${(protein / total * 100).toStringAsFixed(0)}%', radius: 50),
                                      PieChartSectionData(color: Colors.blue, value: carbs, title: '${(carbs / total * 100).toStringAsFixed(0)}%', radius: 50),
                                      PieChartSectionData(color: Colors.orange, value: fats, title: '${(fats / total * 100).toStringAsFixed(0)}%', radius: 50),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Indicator(color: Colors.green, text: 'Protein'),
                            SizedBox(width: 10),
                            Indicator(color: Colors.blue, text: 'Carbohydrates'),
                            SizedBox(width: 10),
                            Indicator(color: Colors.orange, text: 'Fats'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Detailed Breakdown Card
                Card(
                  color: const Color(0xFF2C125A),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Detailed Breakdown', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        NutritionDetailRow(title: 'Calories', value: nutritionData['calories'] ?? 'N/A'),
                        NutritionDetailRow(title: 'Protein', value: nutritionData['protein'] ?? 'N/A'),
                        NutritionDetailRow(title: 'Carbohydrates', value: nutritionData['carbohydrates'] ?? 'N/A'),
                        NutritionDetailRow(title: 'Fats', value: nutritionData['fats'] ?? 'N/A'),
                        NutritionDetailRow(title: 'Fiber', value: nutritionData['fiber'] ?? 'N/A'),
                        NutritionDetailRow(title: 'Sodium', value: nutritionData['sodium'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class NutritionDetailRow extends StatelessWidget {
  final String title;
  final String value;
  const NutritionDetailRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
