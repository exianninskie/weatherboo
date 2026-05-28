import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class GeminiService {
  late GenerativeModel _model;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _model = GenerativeModel(
        model: 'gemini-1.0-pro',
        apiKey: AppConstants.geminiApiKey,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Gemini: $e');
      rethrow;
    }
  }

  Future<String> generateResponse({
    required String userMessage,
    String? weatherContext,
    String? location,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      String systemPrompt = '''You are Weatherboo, a friendly and cute weather assistant. 
Your personality is wholesome, kawaii, and helpful. You use emojis occasionally to be friendly.
Keep responses concise (under 150 words) and conversational.
You help users with weather-related questions and provide helpful lifestyle tips.''';

      if (weatherContext != null) {
        systemPrompt += '\n\nCurrent weather context: $weatherContext';
      }

      if (location != null) {
        systemPrompt += '\n\nUser location: $location';
      }

      final chat = _model.startChat(
        history: [
          Content.text(systemPrompt),
        ],
      );

      final response = await chat.sendMessage(Content.text(userMessage));
      final text = response.text;

      return text ?? "I'm sorry, I couldn't generate a response. Please try again!";
    } catch (e) {
      debugPrint('Error generating response: $e');
      return "I'm having trouble connecting right now. Please try again later! ☁️";
    }
  }

  Future<String> generateWeatherInsight({
    required double temperature,
    required String condition,
    required String location,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final prompt = '''Based on the current weather in $location:
- Temperature: ${temperature.toStringAsFixed(1)}°C
- Condition: $condition

Provide a brief, friendly weather insight or tip for today. Keep it under 100 words and make it helpful and cute!''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Have a wonderful day!";
    } catch (e) {
      debugPrint('Error generating weather insight: $e');
      return "Hope you have a great day! ☁️";
    }
  }
}
