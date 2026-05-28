import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _desktopNotificationsEnabled = true;
  String _temperatureUnit = 'Celsius';
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userProfile == null) {
      await userProvider.loadCurrentUser();
    }

    if (!mounted) return;
    _syncFromProvider(userProvider);
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: AppTypography.label(13),
      prefixIconColor: AppColors.sakura,
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lavender.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.sky.withValues(alpha: 0.5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.sakura, width: 2),
      ),
    );
  }

  void _syncFromProvider(UserProvider userProvider) {
    final profile = userProvider.userProfile;
    if (profile == null) return;

    setState(() {
      _displayNameController.text = profile['display_name'] ?? '';
      _emailController.text = userProvider.email ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _locationController.text = profile['location'] ?? '';
      _bioController.text = profile['bio'] ?? '';
      _cityController.text = profile['default_city'] ?? '';
      _notificationsEnabled = profile['notifications_enabled'] ?? true;
      _emailNotificationsEnabled = profile['email_notifications_enabled'] ?? true;
      _desktopNotificationsEnabled = profile['desktop_notifications_enabled'] ?? true;
      _temperatureUnit = profile['temperature_unit'] ?? 'Celsius';
    });
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
        title: Text('Edit Profile', style: AppTypography.headline(20)),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: KawaiiBackground(
        child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(16, 250, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 350),
                  _buildProfileHeader(userProvider),
                  const SizedBox(height: 24),
                  _buildProfileForm(userProvider),
                  const SizedBox(height: 24),
                  _buildPreferencesSection(userProvider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        ),
      ),
    ),
    );
  }

  Widget _buildProfileHeader(UserProvider userProvider) {
    return const SizedBox.shrink();
  }

  Widget _buildProfileForm(UserProvider userProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryBlue,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (userProvider.profilePictureUrl != null
                                  ? NetworkImage(userProvider.profilePictureUrl!) as ImageProvider
                                  : null),
                          child: _profileImage == null && userProvider.profilePictureUrl == null
                              ? Text(
                                  (_displayNameController.text.isNotEmpty 
                                      ? _displayNameController.text[0].toUpperCase()
                                      : 'U'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.ivory,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _displayNameController,
                      decoration: _fieldDecoration(
                        labelText: 'Display Name',
                        prefixIcon: Icons.person,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a display name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _fieldDecoration(
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _fieldDecoration(
                  labelText: 'Phone (optional)',
                  prefixIcon: Icons.phone,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: _fieldDecoration(
                  labelText: 'Location (optional)',
                  prefixIcon: Icons.location_on,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: _fieldDecoration(
                  labelText: 'Bio (optional)',
                  prefixIcon: Icons.info_outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(UserProvider userProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditablePreference(
              'Default City',
              _cityController,
              Icons.location_city,
            ),
            const Divider(),
            _buildTemperatureUnitPreference(),
            const Divider(),
            _buildNotificationPreference(),
            const Divider(),
            _buildEmailNotificationPreference(),
            const Divider(),
            _buildDesktopNotificationPreference(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditablePreference(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: _fieldDecoration(labelText: label, prefixIcon: icon),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildTemperatureUnitPreference() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.thermostat, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Temperature Unit',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ),
          DropdownButton<String>(
            value: _temperatureUnit,
            items: const ['Celsius', 'Fahrenheit'].map((String unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _temperatureUnit = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreference() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailNotificationPreference() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.email, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Email Notifications',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ),
          Switch(
            value: _emailNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _emailNotificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNotificationPreference() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.desktop_windows, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Desktop Notifications',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ),
          Switch(
            value: _desktopNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _desktopNotificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.uploadProfilePicture(image);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppColors.mint,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Failed to update profile picture'),
              backgroundColor: AppColors.sakuraDeep,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.sakuraDeep,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      // Update email if changed
      if (_emailController.text != userProvider.email) {
        await userProvider.updateEmail(_emailController.text);
      }

      // Update profile data
      final success = await userProvider.updateProfile({
        'display_name': _displayNameController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'bio': _bioController.text,
        'default_city': _cityController.text,
        'temperature_unit': _temperatureUnit,
        'notifications_enabled': _notificationsEnabled,
        'email_notifications_enabled': _emailNotificationsEnabled,
        'desktop_notifications_enabled': _desktopNotificationsEnabled,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.mint,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to update profile'),
            backgroundColor: AppColors.sakuraDeep,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
