import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Replace with your actual OpenWeatherMap API key
  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Get current weather for a city
  Future<Map<String, dynamic>?> getCurrentWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch current weather: $e');
    }
  }

  // Get 5-day forecast for a city
  Future<Map<String, dynamic>?> get5DayForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch forecast: $e');
    }
  }

  // Get weather by coordinates
  Future<Map<String, dynamic>?> getCurrentWeatherByCoordinates(
      double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch current weather: $e');
    }
  }
}
