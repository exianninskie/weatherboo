import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _proxyBaseUrl = 'https://api.allorigins.win/raw?url=';

  Future<Map<String, dynamic>?> getCurrentWeather(String city) async {
    final uri = Uri.parse(
        '$_baseUrl/weather?q=$city&appid=${AppConstants.weatherApiKey}&units=metric');
    final response = await _fetchWithFallback(uri, 'current weather');
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>?> get5DayForecast(String city) async {
    final uri = Uri.parse(
        '$_baseUrl/forecast?q=$city&appid=${AppConstants.weatherApiKey}&units=metric');
    final response = await _fetchWithFallback(uri, 'forecast');
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>?> getCurrentWeatherByCoordinates(
      double lat, double lon) async {
    final uri = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=${AppConstants.weatherApiKey}&units=metric');
    final response =
        await _fetchWithFallback(uri, 'current weather by coordinates');
    return json.decode(response.body);
  }

  Future<http.Response> _fetchWithFallback(Uri uri, String description) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response;
      }
      throw Exception(
          'Failed to fetch $description: ${response.statusCode} ${response.reasonPhrase ?? ''}');
    } catch (e) {
      if (kIsWeb) {
        try {
          final proxyUri =
              Uri.parse('$_proxyBaseUrl${Uri.encodeComponent(uri.toString())}');
          final proxyResponse = await http.get(proxyUri);
          if (proxyResponse.statusCode == 200) {
            return proxyResponse;
          }
          throw Exception(
              'Proxy fetch failed: ${proxyResponse.statusCode} ${proxyResponse.reasonPhrase ?? ''}');
        } catch (proxyError) {
          throw Exception(
              'Failed to fetch $description: $e; proxy fallback failed: $proxyError');
        }
      }
      throw Exception('Failed to fetch $description: $e');
    }
  }
}
