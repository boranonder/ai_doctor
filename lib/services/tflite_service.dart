import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

enum ModelType {
  skin,
  lung,
}

class TFLiteService {
  static const int inputSize = 224; // Model input size (modify based on your model)
  static const int skinModelInputChannels = 3; // RGB
  static const int lungModelInputChannels = 1; // Grayscale for X-rays
  
  // Singleton pattern
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();
  
  Interpreter? _skinInterpreter;
  Interpreter? _lungInterpreter;
  
  // Initialize models
  Future<void> loadModels() async {
    try {
      _skinInterpreter = await Interpreter.fromAsset('assets/models/skin_model.tflite');
      debugPrint('Skin model loaded successfully');
      
      _lungInterpreter = await Interpreter.fromAsset('assets/models/lung_model.tflite');
      debugPrint('Lung model loaded successfully');
    } catch (e) {
      debugPrint('Error loading models: $e');
    }
  }
  
  // Process the image and run inference
  Future<Map<String, dynamic>> analyzeImage(File imageFile, ModelType modelType) async {
    if ((modelType == ModelType.skin && _skinInterpreter == null) || 
        (modelType == ModelType.lung && _lungInterpreter == null)) {
      await loadModels();
    }
    
    // Decode the image
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      return {'error': 'Could not decode image'};
    }
    
    // Resize and preprocess the image
    img.Image resizedImage = img.copyResize(
      image, 
      width: inputSize,
      height: inputSize,
    );
    
    // Convert to required format based on model type
    var inputData = Float32List(
      inputSize * inputSize * 
      (modelType == ModelType.skin ? skinModelInputChannels : lungModelInputChannels)
    );
    
    // Normalize pixel values from [0, 255] to [0, 1]
    var inputIndex = 0;
    
    if (modelType == ModelType.skin) {
      // RGB processing
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();
          
          // Extract RGB values and normalize
          inputData[inputIndex++] = r / 255.0;
          inputData[inputIndex++] = g / 255.0;
          inputData[inputIndex++] = b / 255.0;
        }
      }
    } else {
      // Grayscale processing for X-rays
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();
          
          // Convert to grayscale and normalize
          final gray = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
          inputData[inputIndex++] = gray;
        }
      }
    }
    
    // Prepare input shape
    int numChannels = modelType == ModelType.skin ? skinModelInputChannels : lungModelInputChannels;
    
    // Reshape input data to match model's expected shape
    var inputShape = [1, inputSize, inputSize, numChannels]; // [batch, height, width, channels]
    var outputShape = modelType == ModelType.skin 
      ? [1, 7] // Example: 7 skin condition categories
      : [1, 5]; // Example: 5 lung condition categories
    
    // Prepare output buffer
    var outputBuffer = List<List<double>>.filled(
      outputShape[0], 
      List<double>.filled(outputShape[1], 0)
    );
    
    // Run inference
    try {
      if (modelType == ModelType.skin) {
        _skinInterpreter!.run(
          [inputData], 
          outputBuffer
        );
      } else {
        _lungInterpreter!.run(
          [inputData], 
          outputBuffer
        );
      }
      
      // Process results
      List<double> outputList = outputBuffer[0];
      
      // Find prediction with highest confidence
      double maxConfidence = outputList.reduce((curr, next) => curr > next ? curr : next);
      int predictedClassIndex = outputList.indexOf(maxConfidence);
      
      // Convert class index to label
      String label = _getLabel(predictedClassIndex, modelType);
      
      return {
        'label': label,
        'confidence': maxConfidence,
        'probabilities': outputList,
      };
    } catch (e) {
      return {'error': 'Error during inference: $e'};
    }
  }
  
  // Helper method to convert class index to human-readable label
  String _getLabel(int classIndex, ModelType modelType) {
    if (modelType == ModelType.skin) {
      // Define your skin condition classes here
      List<String> skinLabels = [
        'Acne', 
        'Eczema', 
        'Melanoma', 
        'Psoriasis',
        'Rosacea',
        'Skin Tag',
        'Wart'
      ];
      return skinLabels[classIndex];
    } else {
      // Define your lung condition classes here
      List<String> lungLabels = [
        'Normal', 
        'Pneumonia', 
        'COVID-19', 
        'Tuberculosis',
        'Lung Cancer'
      ];
      return lungLabels[classIndex];
    }
  }
  
  void dispose() {
    _skinInterpreter?.close();
    _lungInterpreter?.close();
  }
} 