import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';

class SocialCommunityScreen extends StatelessWidget {
  const SocialCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(decoration: AppTheme.appBarGradient),
        title: Text('Social & Community', style: AppTypography.headline(20)),
      ),
      body: KawaiiBackground(
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.sakura),
                      const SizedBox(height: 16),
                      Text(
                        'Social & Community',
                        style: AppTypography.headline(24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coming Soon',
                        style: AppTypography.body(16, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connect with others, share wholesome weather moments, and build community.',
                        style: AppTypography.body(14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
