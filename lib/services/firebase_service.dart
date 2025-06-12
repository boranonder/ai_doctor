import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  
  late final HttpsCallable _analyzeImageFunction;
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Firebase Auth ile anonim giriş yap (Firebase Functions için gerekli)
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      
      // Firebase Functions'a referans oluştur
      _analyzeImageFunction = FirebaseFunctions.instance.httpsCallable('analyzeImage');
      _isInitialized = true;
      debugPrint('Firebase Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Service: $e');
      rethrow;
    }
  }
  
  // Hugging Face API'yi Firebase Functions üzerinden çağır
  Future<Map<String, dynamic>> analyzeImage({
    required File imageFile,
    required bool isSkinAnalysis,
  }) async {
    try {
      await initialize();
      
      // Görüntüyü Base64'e dönüştür
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Cloud Function'a istek gönder
      final result = await _analyzeImageFunction.call({
        'imageBase64': base64Image,
        'isSkinAnalysis': isSkinAnalysis,
      });
      
      final data = result.data;
      
      // Yanıtı kontrol et
      if (data['success'] == true) {
        return _processResponse(data['data'], isSkinAnalysis);
      } else {
        return {
          'error': 'API isteği başarısız oldu: ${data['error']}',
        };
      }
    } catch (e) {
      debugPrint('Exception during Firebase Function call: $e');
      return {'error': 'Analiz sırasında bir hata oluştu: $e'};
    }
  }
  
  // API yanıtını işle ve formatla (HuggingFace servisindekine benzer)
  Map<String, dynamic> _processResponse(dynamic response, bool isSkinAnalysis) {
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