import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  // This API key should not be kept in the app,
  // store this value on server-side in a real application
  static const String _apiKey = 'API_KEY'; 
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Singleton pattern
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();
  
  // API request to evaluate image analysis and TFLite results
  Future<String> analyzeResults({
    required File imageFile,
    required String modelResult,
    required String modelType,
  }) async {
    try {
      // GPT-3.5 Turbo model doesn't directly support images,
      // so we'll only use text information
      
      // Prepare request messages
      final messages = [
        {
          "role": "system",
          "content": "You are a medical assistant specialized in analyzing $modelType images. Provide detailed analysis in English language. Include possible conditions, recommendations, and a disclaimer about AI limitations."
        },
        {
          "role": "user",
          "content": "Please evaluate these image analysis results: $modelResult. This is an analysis result for a $modelType scan. Please assess these results and provide a detailed analysis including possible diagnoses, recommendations, and a disclaimer about AI limitations. Respond in English."
        }
      ];
      
      // Send API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // More economical model
          'messages': messages,
          'max_tokens': 800,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
        return 'API request failed: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return 'An error occurred during analysis: $e';
    }
  }
} 