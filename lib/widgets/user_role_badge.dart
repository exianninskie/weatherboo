import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class UserRoleBadge extends StatelessWidget {
  const UserRoleBadge({
    super.key,
    required this.displayName,
    this.profilePictureUrl,
    this.small = true,
  });

  final String displayName;
  final String? profilePictureUrl;
  final bool small;

  static String getRoleLabel(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'ninskie':
        return 'Creator';
      case 'test-user':
        return 'Main Tester';
      case 'test-user2':
        return 'Multi-user Tester';
      default:
        return 'Weatherboo user';
    }
  }

  static Color getBadgeColor(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'ninskie':
        return AppColors.lavender;
      case 'test-user':
        return AppColors.sky;
      case 'test-user2':
        return AppColors.sakura;
      default:
        return AppColors.mint;
    }
  }

  static IconData getBadgeIcon(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'ninskie':
        return Icons.star;
      case 'test-user':
      case 'test-user2':
        return Icons.verified;
      default:
        return Icons.person;
    }
  }

  void _showUserRoleSheet(BuildContext context) {
    final roleLabel = getRoleLabel(displayName);
    final showRole = roleLabel != 'Weatherboo user';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.surfaceElevated,
                backgroundImage: profilePictureUrl != null
                    ? NetworkImage(profilePictureUrl!)
                    : null,
                child: profilePictureUrl == null
                    ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'W',
                        style: AppTypography.headline(28,
                            color: AppColors.sakuraDeep),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: AppTypography.headline(20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                roleLabel,
                style: AppTypography.body(14,
                    color: showRole ? AppColors.text : AppColors.textMuted,
                    weight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: getBadgeColor(displayName),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getBadgeIcon(displayName),
                  color: AppColors.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                showRole
                    ? 'Tap again to close this role card.'
                    : 'This is a Weatherboo user.',
                style: AppTypography.body(13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = small ? 22.0 : 28.0;
    final iconSize = small ? 12.0 : 16.0;

    return GestureDetector(
      onTap: () => _showUserRoleSheet(context),
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          color: getBadgeColor(displayName),
          shape: BoxShape.circle,
        ),
        child: Icon(
          getBadgeIcon(displayName),
          size: iconSize,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
