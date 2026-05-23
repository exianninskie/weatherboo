import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/responsive_center.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  Future<void> _initializeProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userProfile == null) {
      await userProvider.loadCurrentUser();
    }
  }

  Future<void> _signOut() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        flexibleSpace: Container(decoration: AppTheme.appBarGradient),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            tooltip: 'Edit Profile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: KawaiiBackground(
        child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = userProvider.userProfile;
          final displayName = profile?['display_name'] ?? 'Weather User';
          final email = userProvider.email ?? 'user@weatherboo.com';
          final bio = profile?['bio'] ?? '';
          final location = profile?['location'] ?? '';
          final profilePictureUrl = userProvider.profilePictureUrl;

          return SingleChildScrollView(
            child: ResponsiveCenter(
              padding: const EdgeInsets.fromLTRB(16, 260, 16, 16),
              child: Column(
                children: [
                  // Profile Header
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: profilePictureUrl != null
                                ? NetworkImage(profilePictureUrl)
                                : null,
                            child: profilePictureUrl == null
                                ? Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.sakuraDeep,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: AppTypography.headline(20),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: AppTypography.body(14, color: AppColors.textMuted),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (location.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: AppColors.sakura),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: AppTypography.body(13, color: AppColors.textMuted),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          bio,
                          style: AppTypography.body(14),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Stats Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Days Active', '42'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Cities', '12'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Alerts', '23'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preferences Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weather Preferences',
                            style: AppTypography.headline(16, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          _buildPreferenceRow(
                            Icons.location_city,
                            'Default City',
                            profile?['default_city'] ?? 'Not set',
                          ),
                          const Divider(height: 24),
                          _buildPreferenceRow(
                            Icons.thermostat,
                            'Temperature Unit',
                            profile?['temperature_unit'] ?? 'Celsius',
                          ),
                          const Divider(height: 24),
                          _buildPreferenceRow(
                            Icons.notifications,
                            'Notifications',
                            profile?['notifications_enabled'] == true ? 'Enabled' : 'Disabled',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headline(24, color: AppColors.sakuraDeep),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.label(12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.sakura, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body(14, color: AppColors.textMuted),
          ),
        ),
        Text(
          value,
          style: AppTypography.body(14, weight: FontWeight.w600),
        ),
      ],
    );
  }
}
