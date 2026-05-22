import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  String _temperatureUnit = 'Celsius';
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
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

  Future<void> _loadCurrentUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadCurrentUser();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userProfile != null) {
      _displayNameController.text = userProvider.userProfile!['display_name'] ?? '';
      _emailController.text = userProvider.email ?? '';
      _phoneController.text = userProvider.userProfile!['phone'] ?? '';
      _locationController.text = userProvider.userProfile!['location'] ?? '';
      _bioController.text = userProvider.userProfile!['bio'] ?? '';
      _cityController.text = userProvider.userProfile!['default_city'] ?? 'New York';
      _notificationsEnabled = userProvider.userProfile!['notifications_enabled'] ?? true;
      _temperatureUnit = userProvider.userProfile!['temperature_unit'] ?? 'Celsius';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
            color: Colors.white,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileHeader(userProvider),
                const SizedBox(height: 24),
                _buildProfileForm(userProvider),
                const SizedBox(height: 24),
                _buildPreferencesSection(userProvider),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProvider userProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickProfileImage : null,
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
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _displayNameController.text.isNotEmpty 
                        ? _displayNameController.text
                        : 'Weather User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _emailController.text.isNotEmpty 
                        ? _emailController.text
                        : 'user@weatherboo.com',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Quicksand',
                      color: AppColors.textLight,
                    ),
                  ),
                  if (_locationController.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _locationController.text,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Quicksand',
                              color: AppColors.textLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Quicksand',
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  fontFamily: 'Quicksand',
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
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
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Phone (optional)',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'Location (optional)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                enabled: _isEditing,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio (optional)',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelEdit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
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
                fontFamily: 'Quicksand',
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditablePreference(
              'Default City',
              _cityController,
              Icons.location_city,
              _isEditing,
            ),
            const Divider(),
            _buildTemperatureUnitPreference(),
            const Divider(),
            _buildNotificationPreference(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditablePreference(String label, TextEditingController controller, IconData icon, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Quicksand',
                      color: AppColors.textLight,
                    ),
                  ),
          ),
          if (!isEditing)
            Text(
              controller.text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
                color: AppColors.textDark,
              ),
            ),
        ],
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
                fontFamily: 'Quicksand',
                color: AppColors.textLight,
              ),
            ),
          ),
          if (_isEditing)
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
            )
          else
            Text(
              _temperatureUnit,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
                color: AppColors.textDark,
              ),
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
                fontFamily: 'Quicksand',
                color: AppColors.textLight,
              ),
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: _isEditing
                ? (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Quicksand',
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Days Active', _calculateDaysActive()),
                ),
                Expanded(
                  child: _buildStatItem('Cities Checked', '12'),
                ),
                Expanded(
                  child: _buildStatItem('Alerts Received', '23'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Profile Complete', _calculateProfileComplete()),
                ),
                Expanded(
                  child: _buildStatItem('Weather Views', '156'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDaysActive() {
    // This would be calculated from actual user data
    // For now, return a placeholder
    return '42';
  }

  String _calculateProfileComplete() {
    int filledFields = 0;
    int totalFields = 5;
    
    if (_displayNameController.text.isNotEmpty) filledFields++;
    if (_emailController.text.isNotEmpty) filledFields++;
    if (_phoneController.text.isNotEmpty) filledFields++;
    if (_locationController.text.isNotEmpty) filledFields++;
    if (_bioController.text.isNotEmpty) filledFields++;
    
    final percentage = ((filledFields / totalFields) * 100).round();
    return '$percentage%';
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Quicksand',
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Quicksand',
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
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
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Failed to update profile picture'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reset to original values
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
      });

      if (success) {
        setState(() {
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
