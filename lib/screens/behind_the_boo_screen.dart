import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class BehindTheBooScreen extends StatelessWidget {
  const BehindTheBooScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingAvatarOverlay(
      initialMessage: 'Halo! 👋 Explore Behind The Boo',
      initiallyVisible: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(decoration: AppTheme.appBarGradient),
          title: Text('Behind The Boo', style: AppTypography.headline(20)),
        ),
        body: KawaiiBackground(
          child: ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(16, 240, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Column(
                      children: [
                        const Icon(Icons.auto_stories_outlined,
                            size: 56, color: AppColors.sakura),
                        const SizedBox(height: 12),
                        Text(
                          'Discover the magic behind Weatherboo',
                          style: AppTypography.headline(20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Weatherboo brings pastel weather guidance, mood support, and cozy lifestyle inspiration into a single playful experience.',
                          style: AppTypography.body(13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  title: 'Our story',
                  content:
                      'Weatherboo started as a little idea: what if a weather app could also bring warmth, comfort, and a sense of community to your daily routine?',
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  title: 'How it helps',
                  content:
                      'From outfit suggestions to mindfulness prompts, Weatherboo is designed to help you feel confident and supported no matter what the forecast says.',
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  title: 'Where we are headed',
                  content:
                      'We dream of evolving Weatherboo into a personal lifestyle companion that keeps you inspired, centered, and always ready for the next weather adventure.',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      color: AppColors.surfaceElevated.withValues(alpha: 0.95),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.headline(18, color: AppColors.sakuraDeep),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: AppTypography.body(14, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
