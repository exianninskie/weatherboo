import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_center.dart';

class SelfCareWellnessScreen extends StatelessWidget {
  const SelfCareWellnessScreen({super.key});

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
        title: Text('Self-Care & Wellness', style: AppTypography.headline(20)),
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
                      Icon(Icons.self_improvement_outlined, size: 64, color: AppColors.sakura),
                      const SizedBox(height: 16),
                      Text(
                        'Self-Care & Wellness',
                        style: AppTypography.headline(24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coming Soon',
                        style: AppTypography.body(16, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Weather-based self-care reminders, wellness tips, and gratitude journaling.',
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
