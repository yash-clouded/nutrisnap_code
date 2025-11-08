
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NutisnapService {
  final String? _apiKey = dotenv.env['USDA_API_KEY'];

  // Helper function to find a nutrient value from the list
  String _getNutrientValue(List<dynamic> nutrients, int nutrientId) {
    final nutrient = nutrients.firstWhere(
      (n) => n['nutrient']['id'] == nutrientId,
      orElse: () => null,
    );
    if (nutrient != null && nutrient['amount'] != null) {
      final amount = nutrient['amount'] as double;
      final unit = nutrient['nutrient']['unitName'].toLowerCase();
      return '${amount.toStringAsFixed(1)} $unit';
    }
    return 'N/A';
  }

  Future<Map<String, dynamic>> getNutritionByFoodName(String foodName) async {
    if (_apiKey == null) {
      throw Exception("USDA API Key not found. Make sure you have a .env file with USDA_API_KEY set.");
    }

    // --- Step 1: Search for the food to get its fdcId ---
    final searchUrl = Uri.parse('https://api.nal.usda.gov/fdc/v1/foods/search?api_key=$_apiKey&query=${Uri.encodeComponent(foodName)}');
    final searchResponse = await http.get(searchUrl);

    if (searchResponse.statusCode != 200) {
      throw Exception('Failed to search for food in USDA database. Status: ${searchResponse.statusCode}');
    }

    final searchResults = jsonDecode(searchResponse.body);
    if (searchResults['foods'] == null || searchResults['foods'].isEmpty) {
      throw Exception('Food "$foodName" not found in USDA database.');
    }

    // Take the first result's fdcId
    final fdcId = searchResults['foods'][0]['fdcId'];

    // --- Step 2: Use the fdcId to get detailed nutrition information ---
    final detailsUrl = Uri.parse('https://api.nal.usda.gov/fdc/v1/food/$fdcId?api_key=$_apiKey');
    final detailsResponse = await http.get(detailsUrl);

    if (detailsResponse.statusCode != 200) {
      throw Exception('Failed to get nutrition details from USDA. Status: ${detailsResponse.statusCode}');
    }

    final detailsResult = jsonDecode(detailsResponse.body);
    final nutrients = detailsResult['foodNutrients'] as List<dynamic>;

    // --- Step 3: Parse the complex response into a simple map ---
    final nutritionMap = {
      'calories': _getNutrientValue(nutrients, 1008), // Energy in Kcal
      'protein': _getNutrientValue(nutrients, 1003),  // Protein
      'carbohydrates': _getNutrientValue(nutrients, 1005), // Carbohydrate, by difference
      'fats': _getNutrientValue(nutrients, 1004),      // Total lipid (fat)
      'fiber': _getNutrientValue(nutrients, 1079),     // Fiber, total dietary
      'sodium': _getNutrientValue(nutrients, 1093),    // Sodium, Na
      'sugar': _getNutrientValue(nutrients, 2000),     // Sugars, total including NLEA
    };

    nutritionMap['food_name'] = foodName; // Add food name for context
    return nutritionMap;
  }

  Future<String> getSummary(Map<String, dynamic> nutritionData) async {
    final url = Uri.parse('http://54.172.186.81:8000/summarize');
    
    double _parse(String? value) {
        if (value == null) return 0.0;
        final numericPart = value.replaceAll(RegExp(r'[^-0-9.]'), '');
        return double.tryParse(numericPart) ?? 0.0;
    }

    final requestBody = {
      'calories': _parse(nutritionData['calories']),
      'protein': _parse(nutritionData['protein']),
      'fat': _parse(nutritionData['fats']), // Key change
      'carbs': _parse(nutritionData['carbohydrates']), // Key change
      'fiber': _parse(nutritionData['fiber']),
      'sugar': _parse(nutritionData['sugar']), 
      'sodium': _parse(nutritionData['sodium']),
      'extra_context': nutritionData['food_name'] ?? 'N/A',
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['summary'] as String;
    } else {
      throw Exception('Failed to generate summary: ${response.body}');
    }
  }
}
