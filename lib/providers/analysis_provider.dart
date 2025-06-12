import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/openai_service.dart';
import '../services/huggingface_service.dart';

enum AnalysisType {
  skin,
  lung,
  brain,
  eye,
  dental,
}

class AnalysisProvider with ChangeNotifier {
  AnalysisType? _analysisType;
  File? _selectedImage;
  String? _analysisResult;
  String? _modelResult;
  String? _openAIResult;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  
  // Services
  final OpenAIService _openAIService = OpenAIService();
  final HuggingFaceService _huggingFaceService = HuggingFaceService();

  AnalysisType? get analysisType => _analysisType;
  File? get selectedImage => _selectedImage;
  String? get analysisResult => _analysisResult;
  String? get modelResult => _modelResult;
  String? get openAIResult => _openAIResult;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;

  void setAnalysisType(AnalysisType type) {
    _analysisType = type;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        _selectedImage = File(image.path);
        _analysisResult = null;
        _modelResult = null;
        _openAIResult = null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeImage() async {
    if (_selectedImage == null || _analysisType == null) return;

    _isAnalyzing = true;
    notifyListeners();

    try {
      // 1. Hugging Face ile doğrudan analiz
      final String analysisTypeStr = _analysisType.toString().split('.').last;
      final modelResults = await _huggingFaceService.analyzeImage(
        imageFile: _selectedImage!,
        analysisType: analysisTypeStr,
      );
      
      // 2. Sonuçları formatla
      if (modelResults.containsKey('error')) {
        _modelResult = 'Analiz hatası: ${modelResults['error']}';
        _analysisResult = _modelResult;
      } else {
        final label = modelResults['label'] as String;
        final confidence = (modelResults['confidence'] as double) * 100;
        _modelResult = 'Tespit edilen durum: $label (Güven: ${confidence.toStringAsFixed(2)}%)';
        
        // Detaylı sonuçları göster
        String detailedResults = 'Tüm Olası Durumlar:\n';
        final allResults = modelResults['allResults'] as List<Map<String, dynamic>>;
        
        for (var result in allResults) {
          final resultLabel = result['label'] as String;
          final resultConfidence = (result['confidence'] as double) * 100;
          detailedResults += '- $resultLabel: ${resultConfidence.toStringAsFixed(2)}%\n';
        }
        
        _analysisResult = '$_modelResult\n\n$detailedResults';
        
        // 3. OpenAI ile detaylı analiz yap
        String analysisTypeForOpenAI;
        switch (_analysisType) {
          case AnalysisType.skin:
            analysisTypeForOpenAI = 'cilt';
            break;
          case AnalysisType.lung:
            analysisTypeForOpenAI = 'akciğer röntgeni';
            break;
          case AnalysisType.brain:
            analysisTypeForOpenAI = 'beyin MRI';
            break;
          case AnalysisType.eye:
            analysisTypeForOpenAI = 'göz retina';
            break;
          case AnalysisType.dental:
            analysisTypeForOpenAI = 'diş';
            break;
          default:
            analysisTypeForOpenAI = 'tıbbi görüntü';
        }
        
        _openAIResult = await _openAIService.analyzeResults(
          imageFile: _selectedImage!,
          modelResult: _modelResult ?? 'Sonuç bulunamadı',
          modelType: analysisTypeForOpenAI,
        );
        
        // 4. Sonuçları birleştir
        _analysisResult = '$_analysisResult\n\n--- OpenAI Analizi ---\n$_openAIResult';
      }
    } catch (e) {
      _analysisResult = 'Analiz sırasında bir hata oluştu: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _analysisResult = null;
    _modelResult = null;
    _openAIResult = null;
    notifyListeners();
  }
} 