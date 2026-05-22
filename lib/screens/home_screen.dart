import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(decoration: AppTheme.appBarGradient),
        title: Text('Weatherboo', style: AppTypography.brandTitle(20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: KawaiiBackground(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomLogo(
                        size: MediaQuery.of(context).size.width * 0.32,
                        showFull: true,
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Your cozy forecast ☁️',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (userProvider.email != null)
                        Text(
                          'Logged in as ${userProvider.email}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.sakuraDeep,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await userProvider.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: const Text('Sign Out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
