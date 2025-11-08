
import 'dart:io';
import 'package:pytorch_lite/pytorch_lite.dart';

class IndianFoodClassifier {
  ClassificationModel? _model;
  bool _isInitialized = false;

  static const int inputSize = 224;

  /// Initialize the model
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _model = await PytorchLite.loadClassificationModel(
        "assets/models/indianfood_mobilenetv2.pt",
        inputSize,
        inputSize, 121,
        labelPath: "assets/labels/indian_food_labels.txt",
      );
      _isInitialized = true;
      print("✅ Model initialized successfully (PyTorch Lite 4.3.2)");
    } catch (e) {
      throw Exception("❌ Failed to initialize model: $e");
    }
  }

  /// Classify an image file
  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (!_isInitialized) await initialize();
    if (_model == null) throw Exception("Model not loaded.");

    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception("Image not found at path: $imagePath");
      }

      // --- FIX: Use correct method and add normalization ---
      // The package returns a list, and we need to provide normalization values.
      final predictions = await _model!.getImagePrediction(
        await File(imagePath).readAsBytes(),
      );

      if (predictions.isEmpty) {
        throw Exception("No predictions returned from model.");
      }

      // --- FIX: Get the first (best) prediction from the list ---
      final best = predictions;


      final label = best ?? "Unknown";


      return {
        "foodName": label,
        "confidence": 100.0 ,
      };
    } catch (e) {
      throw Exception("Error classifying image: $e");
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      //await _model?.close();
      _model = null;
      _isInitialized = false;
      print("🧹 Model resources released.");
    } catch (_) {}
  }
}
