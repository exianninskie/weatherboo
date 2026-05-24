import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/user_provider.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/interactive_avatar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const WeatherbooApp());
}

class WeatherbooApp extends StatelessWidget {
  const WeatherbooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Weatherboo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.kawaii,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => FloatingAvatarOverlay(
            initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
            initiallyVisible: true,
            child: const SplashScreen(),
          ),
          '/login': (context) => FloatingAvatarOverlay(
            initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
            initiallyVisible: true,
            child: const LoginScreen(),
          ),
          '/signup': (context) => FloatingAvatarOverlay(
            initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
            initiallyVisible: true,
            child: const SignupScreen(),
          ),
          '/home': (context) => FloatingAvatarOverlay(
            initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
            initiallyVisible: true,
            child: const HomeScreen(),
          ),
          '/profile': (context) => FloatingAvatarOverlay(
            initialMessage: 'Halo! 👋 Welcome to Weatherboo!',
            initiallyVisible: true,
            child: const ProfileScreen(),
          ),
        },
      ),
    );
  }
}
