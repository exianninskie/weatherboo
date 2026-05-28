import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/weather_service.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class OutfitLifestyleScreen extends StatefulWidget {
  const OutfitLifestyleScreen({super.key});

  @override
  State<OutfitLifestyleScreen> createState() => _OutfitLifestyleScreenState();
}

class _OutfitLifestyleScreenState extends State<OutfitLifestyleScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = 'New York';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;
    final targetCity = profile?['default_city'] ?? 'New York';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentCity = targetCity;
    });

    try {
      final currentWeather = await _weatherService.getCurrentWeather(targetCity);

      if (mounted) {
        setState(() {
          _currentWeather = currentWeather;
          _isLoading = false;
        });
        debugPrint('Weather loaded for $targetCity: $currentWeather');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        debugPrint('Error loading weather: $e');
      }
    }
  }

  String _getTemperatureRange(double tempCelsius) {
    if (tempCelsius < 5) return 'cold';
    if (tempCelsius < 15) return 'cool';
    if (tempCelsius < 25) return 'mild';
    return 'hot';
  }

  String _getWeatherCondition(String? weatherMain) {
    if (weatherMain == null) return 'clear';

    final condition = weatherMain.toLowerCase();

    // Map specific OpenWeatherMap conditions to broader categories
    final conditionMapping = {
      // Clear
      'clear sky': 'clear',
      'clear': 'clear',

      // Clouds
      'few clouds': 'clouds',
      'scattered clouds': 'clouds',
      'broken clouds': 'clouds',
      'overcast clouds': 'clouds',
      'clouds': 'clouds',
      'cloud': 'clouds',

      // Rain
      'light rain': 'rain',
      'moderate rain': 'rain',
      'heavy intensity rain': 'rain',
      'very heavy rain': 'rain',
      'extreme rain': 'rain',
      'freezing rain': 'rain',
      'light intensity shower rain': 'rain',
      'shower rain': 'rain',
      'heavy intensity shower rain': 'rain',
      'ragged shower rain': 'rain',
      'rain': 'rain',

      // Drizzle
      'light intensity drizzle': 'drizzle',
      'drizzle': 'drizzle',
      'heavy intensity drizzle': 'drizzle',
      'light intensity drizzle rain': 'drizzle',
      'drizzle rain': 'drizzle',
      'heavy intensity drizzle rain': 'drizzle',
      'shower rain and drizzle': 'drizzle',
      'heavy shower rain and drizzle': 'drizzle',
      'shower drizzle': 'drizzle',

      // Thunderstorm
      'thunderstorm with light rain': 'thunderstorm',
      'thunderstorm with rain': 'thunderstorm',
      'thunderstorm with heavy rain': 'thunderstorm',
      'light thunderstorm': 'thunderstorm',
      'heavy thunderstorm': 'thunderstorm',
      'ragged thunderstorm': 'thunderstorm',
      'thunderstorm with light drizzle': 'thunderstorm',
      'thunderstorm with drizzle': 'thunderstorm',
      'thunderstorm with heavy drizzle': 'thunderstorm',
      'thunderstorm with ragged light rain': 'thunderstorm',
      'thunderstorm with ragged rain': 'thunderstorm',
      'thunderstorm with ragged heavy rain': 'thunderstorm',
      'thunderstorm': 'thunderstorm',

      // Snow
      'light snow': 'snow',
      'heavy snow': 'snow',
      'sleet': 'snow',
      'light shower sleet': 'snow',
      'shower sleet': 'snow',
      'rain and snow': 'snow',
      'light rain and snow': 'snow',
      'light shower snow': 'snow',
      'shower snow': 'snow',
      'heavy shower snow': 'snow',
      'snow': 'snow',

      // Atmosphere
      'mist': 'mist',
      'smoke': 'mist',
      'haze': 'mist',
      'dust': 'mist',
      'fog': 'mist',
      'sand': 'mist',
      'ash': 'mist',
      'squall': 'mist',
      'tornado': 'mist',
    };

    final normalizedCondition = conditionMapping[condition] ?? condition;
    debugPrint('Weather condition from API: $weatherMain, Normalized: $normalizedCondition');
    return normalizedCondition;
  }

  List<String> _getOutfitSuggestions(String tempRange, String weatherCondition) {
    final suggestions = <String>[];

    // Temperature-based clothing
    switch (tempRange) {
      case 'cold':
        suggestions.addAll([
          '🧥 Heavy coat or down jacket',
          '🧣 Warm scarf and gloves',
          '🧢 Thermal hat or beanie',
          '👖 Layered pants or thermal leggings',
        ]);
        break;
      case 'cool':
        suggestions.addAll([
          '🧥 Light jacket or cardigan',
          '🧣 Light scarf optional',
          '👕 Long-sleeve shirt',
          '👖 Regular pants or jeans',
        ]);
        break;
      case 'mild':
        suggestions.addAll([
          '👕 T-shirt or light blouse',
          '🧥 Light layer for evening',
          '👖 Comfortable pants or skirt',
        ]);
        break;
      case 'hot':
        suggestions.addAll([
          '👕 Lightweight breathable shirt',
          '🩳 Shorts or light skirt',
          '👒 Sun hat or cap',
          '🕶️ Sunglasses',
        ]);
        break;
    }

    // Weather-specific additions
    switch (weatherCondition) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        suggestions.addAll([
          '☔ Waterproof jacket or umbrella',
          '👢 Water-resistant footwear',
        ]);
        break;
      case 'snow':
        suggestions.addAll([
          '🥾 Waterproof boots',
          '🧣 Extra warm layers',
        ]);
        break;
      case 'clouds':
      case 'cloudy':
      case 'cloud':
        suggestions.addAll([
          '🧥 Light jacket or cardigan',
          '👕 Comfortable breathable shirt',
        ]);
        break;
      case 'mist':
        suggestions.addAll([
          '🧥 Light jacket or hoodie',
          '👕 Long-sleeve shirt',
          '👖 Comfortable pants',
          '🧣 Light scarf optional',
        ]);
        break;
      case 'clear':
        if (tempRange == 'hot') {
          suggestions.add('🧴 Sunscreen');
        }
        break;
    }

    return suggestions;
  }

  List<String> _getActivitySuggestions(String tempRange, String weatherCondition) {
    switch (weatherCondition) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return [
          '📚 Read a book at a cozy café',
          '🎬 Watch movies or series',
          '🎨 Indoor creative projects',
          '🏠 Home workout or yoga',
          '🍳 Cook a warm meal',
          '🎮 Board games or video games',
        ];
      case 'snow':
        return [
          '⛷️ Skiing or snowboarding',
          '🛷 Sledding or snow tubing',
          '☕ Cozy café with hot chocolate',
          '📖 Reading by the fireplace',
          '🏠 Indoor movie marathon',
          '❄️ Building a snowman',
        ];
      case 'clouds':
      case 'cloudy':
      case 'cloud':
        return [
          '🚶 Outdoor walk or jog',
          '🌳 Visit a park',
          '📸 Nature photography',
          '☕ Outdoor café visit',
          '🏛️ Visit a museum or gallery',
          '🛍️ Shopping at a mall',
        ];
      case 'mist':
        return [
          '🏛️ Visit a museum or gallery',
          '📚 Reading at a café',
          '🎨 Indoor creative projects',
          '🎬 Watch movies or series',
          '🍳 Cook a warm meal',
          '🧘 Indoor yoga or meditation',
        ];
      case 'clear':
        if (tempRange == 'hot') {
          return [
            '🏖️ Beach day or swimming',
            '🎾 Outdoor sports',
            '🧺 Picnic in the park',
            '🚴 Bike riding',
            '🌳 Nature walk or hiking',
            '📸 Outdoor photography',
          ];
        } else {
          return [
            '🚶 Outdoor walk or jog',
            '🌳 Visit a park',
            '📸 Nature photography',
            '🧘 Outdoor yoga',
            '🚴 Cycling',
            '☕ Outdoor café visit',
          ];
        }
      default:
        return [
          '🚶 Light outdoor walk',
          '📚 Reading at home',
          '☕ Café visit',
          '🎨 Creative activities',
        ];
    }
  }

  List<String> _getDrinkPairings(String tempRange, String weatherCondition) {
    final pairings = <String>[];

    // Temperature-based
    switch (tempRange) {
      case 'cold':
      case 'cool':
        pairings.addAll([
          '☕ Hot coffee or latte',
          '🍵 Hot tea (chai, green, herbal)',
          '🍫 Hot chocolate',
          '🧋 Warm bubble tea',
        ]);
        break;
      case 'mild':
        pairings.addAll([
          '☕ Iced or hot coffee',
          '🍵 Fresh tea',
          '🥤 Smoothie',
          '🧋 Bubble tea',
        ]);
        break;
      case 'hot':
        pairings.addAll([
          '🧊 Iced coffee or cold brew',
          '🥤 Fresh fruit juice',
          '🍋 Lemonade or iced tea',
          '🥭 Mango smoothie',
          '🍧 Ice cream or sorbet',
        ]);
        break;
    }

    // Weather-specific additions
    switch (weatherCondition) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        pairings.addAll([
          '🍵 Comforting herbal tea',
          '☕ Warm spiced latte',
        ]);
        break;
      case 'snow':
        pairings.addAll([
          '🍫 Rich hot chocolate',
          '☕ Warm cider or mulled wine',
        ]);
        break;
      case 'clouds':
      case 'cloudy':
      case 'cloud':
        pairings.addAll([
          '☕ Iced or hot coffee',
          '🍵 Fresh tea',
          '🥤 Smoothie',
        ]);
        break;
      case 'mist':
        pairings.addAll([
          '☕ Hot coffee or latte',
          '🍵 Warm herbal tea',
          '🍫 Hot chocolate',
          '🧋 Warm bubble tea',
        ]);
        break;
      case 'clear':
        if (tempRange != 'hot') {
          pairings.add('🍹 Refreshing mocktail');
        }
        break;
    }

    return pairings;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingAvatarOverlay(
      initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
      initiallyVisible: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(decoration: AppTheme.appBarGradient),
        title: Text('Outfit & Lifestyle', style: AppTypography.headline(20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: KawaiiBackground(
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(16, 250, 16, 16),
          child: _buildContent(),
        ),
      ),
    ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.sakuraDeep),
            const SizedBox(height: 16),
            Text(
              'Failed to load weather',
              style: AppTypography.headline(20),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTypography.body(14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadWeather,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentWeather == null) {
      return Center(
        child: Text(
          'No weather data available',
          style: AppTypography.body(16),
        ),
      );
    }

    final temp = _currentWeather!['main']['temp'] as double;
    final weatherMain = _currentWeather!['weather'][0]['main'] as String;
    final tempRange = _getTemperatureRange(temp);
    final weatherCondition = _getWeatherCondition(weatherMain);

    debugPrint('Temperature: $temp°C, Range: $tempRange, Weather: $weatherMain, Condition: $weatherCondition');

    final outfitSuggestions = _getOutfitSuggestions(tempRange, weatherCondition);
    final activitySuggestions = _getActivitySuggestions(tempRange, weatherCondition);
    final drinkPairings = _getDrinkPairings(tempRange, weatherCondition);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherHeader(temp, weatherMain),
          const SizedBox(height: 24),
          _buildOutfitCard(outfitSuggestions),
          const SizedBox(height: 20),
          _buildActivityCard(activitySuggestions),
          const SizedBox(height: 20),
          _buildDrinkCard(drinkPairings),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(double temp, String weatherMain) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;
    final temperatureUnit = profile?['temperature_unit'] ?? 'Celsius';
    final displayTemp = temperatureUnit == 'Fahrenheit' ? (temp * 9/5 + 32).round() : temp.round();
    final tempUnit = temperatureUnit == 'Fahrenheit' ? '°F' : '°C';

    return Card(
      elevation: 4,
      color: Colors.black.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.sakura.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.sakura.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getWeatherIcon(weatherMain),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentCity,
                    style: AppTypography.headline(18, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$displayTemp$tempUnit • ${weatherMain[0].toUpperCase()}${weatherMain.substring(1)}',
                    style: AppTypography.body(14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  Widget _buildOutfitCard(List<String> suggestions) {
    return _buildFeatureCard(
      icon: Icons.checkroom_outlined,
      title: 'Smart Outfit Suggestions',
      subtitle: 'AI-powered recommendations for today',
      color: AppColors.sakura,
      items: suggestions,
    );
  }

  Widget _buildActivityCard(List<String> suggestions) {
    return _buildFeatureCard(
      icon: Icons.directions_run_outlined,
      title: 'Weather-Based Activities',
      subtitle: 'Perfect activities for today\'s weather',
      color: AppColors.sky,
      items: suggestions,
    );
  }

  Widget _buildDrinkCard(List<String> suggestions) {
    return _buildFeatureCard(
      icon: Icons.local_cafe_outlined,
      title: 'Coffee & Drink Pairings',
      subtitle: 'Beverage recommendations for today',
      color: AppColors.lavender,
      items: suggestions,
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> items,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headline(18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.body(13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.body(14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
