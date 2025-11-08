
import 'dart:io';
import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'nutrition_summary_screen.dart';
import 'nutisnap_service.dart';
import 'indian_food_classifier.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? _imagePath;
  final _foodNameController = TextEditingController();
  final _nutisnapService = NutisnapService();
  final _indianFoodClassifier = IndianFoodClassifier();
  bool _isLoading = false;

  Future<void> _openCamera() async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
    if (imagePath == null) return;

    setState(() {
      _imagePath = imagePath;
      _foodNameController.clear();
      _isLoading = true;
    });

    try {
      final classificationResult = await _indianFoodClassifier.classifyImage(imagePath);
      final foodName = classificationResult['foodName'] as String;

      if (!mounted) return;
      setState(() {
        _foodNameController.text = foodName;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not identify food from image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getNutrition() async {
    if (_foodNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a food name.')));
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final nutritionData = await _nutisnapService.getNutritionByFoodName(_foodNameController.text);
      final summary = await _nutisnapService.getSummary(nutritionData);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionSummaryScreen(
            nutritionData: nutritionData,
            summary: summary,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriSnap'),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_imagePath != null)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _openCamera,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 80),
                          SizedBox(height: 10),
                          Text('Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 50),
                if (_imagePath != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.camera_enhance, color: Colors.white),
                        label: const Text('Retake', style: TextStyle(color: Colors.white)),
                        onPressed: _openCamera,
                      ),
                      const SizedBox(width: 20),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        onPressed: () {
                          setState(() {
                            _imagePath = null;
                            _foodNameController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                  child: TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Enter food name to summarize',
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    textAlign: TextAlign.center,
                    onSubmitted: (_) => _getNutrition(),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    onPressed: _getNutrition,
                    child: const Text('Summarize', style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
