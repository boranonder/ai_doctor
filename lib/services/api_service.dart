import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Firebase Function URL - BUNU KENDİ FUNCTION URL'İNİZLE DEĞİŞTİRİN
  static const String _functionUrl = 'https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/analyzeImage';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Görüntü analizi için Firebase Function'a istek gönder
  Future<Map<String, dynamic>> analyzeImage({
    required File imageFile,
    required bool isSkinAnalysis,
  }) async {
    try {
      // Görüntüyü Base64'e dönüştür
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // HTTP POST isteği gönder
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageBase64': base64Image,
          'isSkinAnalysis': isSkinAnalysis,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          return _processResponse(jsonResponse['data']);
        } else {
          return {
            'error': 'API isteği başarısız oldu: ${jsonResponse['error']}',
          };
        }
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
        return {
          'error': 'API isteği başarısız oldu: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Exception during API call: $e');
      return {'error': 'Analiz sırasında bir hata oluştu: $e'};
    }
  }
  
  // API yanıtını işle ve formatla
  Map<String, dynamic> _processResponse(dynamic response) {
    try {
      if (response is List && response.isNotEmpty) {
        final List<Map<String, dynamic>> results = [];
        
        for (var item in response) {
          if (item is Map && item.containsKey('label') && item.containsKey('score')) {
            results.add({
              'label': item['label'],
              'confidence': item['score'],
            });
          }
        }
        
        // Sonuçları güven skoruna göre sırala
        results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
        
        if (results.isNotEmpty) {
          final topResult = results.first;
          return {
            'label': topResult['label'],
            'confidence': topResult['confidence'],
            'allResults': results,
          };
        }
      }
      
      // Format edilemiyor veya boş yanıt durumu
      return {
        'error': 'API yanıtı beklenmeyen formatta',
        'rawResponse': response,
      };
    } catch (e) {
      return {
        'error': 'API yanıtı işlenirken hata oluştu: $e',
        'rawResponse': response,
      };
    }
  }
} 