import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
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
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: profilePictureUrl != null
                                ? NetworkImage(profilePictureUrl)
                                : null,
                            child: profilePictureUrl == null
                                ? Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.sakuraDeep,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: AppTypography.headline(24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: AppTypography.body(14, color: AppColors.textMuted),
                          ),
                          if (bio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                bio,
                                style: AppTypography.body(14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          if (location.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, size: 16, color: AppColors.sakura),
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: AppTypography.body(14, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatItem('Days Active', '42'),
                              const SizedBox(width: 24),
                              _buildStatItem('Cities', '12'),
                              const SizedBox(width: 24),
                              _buildStatItem('Alerts', '23'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.location_city,
                                    label: 'Default City',
                                    value: profile?['default_city'] ?? 'Not set',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.thermostat,
                                    label: 'Temperature',
                                    value: profile?['temperature_unit'] ?? 'Celsius',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildInfoCard(
                              icon: Icons.notifications,
                              label: 'Notifications',
                              value: profile?['notifications_enabled'] == true ? 'Enabled' : 'Disabled',
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
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
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.sakura, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.label(12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.body(14, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
