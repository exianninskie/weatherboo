import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../widgets/responsive_center.dart';
import '../widgets/interactive_avatar.dart';
import '../widgets/user_role_badge.dart';

class CreatorsCornerScreen extends StatefulWidget {
  const CreatorsCornerScreen({super.key});

  @override
  State<CreatorsCornerScreen> createState() => _CreatorsCornerScreenState();
}

class _CreatorsCornerScreenState extends State<CreatorsCornerScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();
  bool _isEditing = false;
  String? _savedNote;

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _createNewNote() {
    setState(() {
      _isEditing = true;
      _noteController.clear();
    });
    FocusScope.of(context).requestFocus(_noteFocus);
  }

  void _clearNote() {
    setState(() {
      _savedNote = null;
      _isEditing = false;
      _noteController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inspiration note deleted.')),
    );
  }

  void _submitNote() {
    if (_noteController.text.trim().isEmpty) return;
    setState(() {
      _savedNote = _noteController.text.trim();
      _isEditing = false;
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inspiration note saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;
    final profilePictureUrl = userProvider.profilePictureUrl;
    final displayName = profile?['display_name']?.toString() ?? 'Ninskie';

    return FloatingAvatarOverlay(
      initialMessage: 'Halo! 👋 Welcome to The Creator\'s Corner',
      initiallyVisible: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(decoration: AppTheme.appBarGradient),
          title:
              Text("The Creator's Corner", style: AppTypography.headline(20)),
        ),
        body: KawaiiBackground(
          child: ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(16, 240, 16, 16),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildContent(displayName, profilePictureUrl),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String displayName, String? profilePictureUrl) {
    final roleLabel = UserRoleBadge.getRoleLabel(displayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.sakura,
                      backgroundImage: profilePictureUrl != null
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl == null
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'N',
                              style: const TextStyle(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTypography.headline(18,
                                color: AppColors.sakuraDeep),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              UserRoleBadge(
                                displayName: displayName,
                                profilePictureUrl: profilePictureUrl,
                                small: false,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                roleLabel,
                                style: AppTypography.body(12,
                                    color: AppColors.textMuted,
                                    weight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Today’s inspiration',
                        style: AppTypography.headline(22),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _createNewNote,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New note'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isEditing) ...[
                  TextField(
                    focusNode: _noteFocus,
                    controller: _noteController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submitNote(),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    maxLength: 10000,
                    maxLines: 6,
                    style: AppTypography.body(14, color: AppColors.text),
                    decoration: InputDecoration(
                      hintText:
                          'Share a thought, an update, or some Weatherboo inspiration for today...',
                      hintStyle:
                          AppTypography.body(14, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColors.lavender.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColors.lavender.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.sakura,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _noteController.text.trim().isNotEmpty
                            ? _submitNote
                            : null,
                        icon: const Text('🚀', style: TextStyle(fontSize: 18)),
                        label: const Text('Submit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed:
                            _noteController.text.isNotEmpty ? _clearNote : null,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ] else if (_savedNote != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _savedNote!,
                      style: AppTypography.body(14, color: AppColors.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _createNewNote,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit note'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _clearNote,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Tap + New note to start your creator card.',
                      style: AppTypography.body(14, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
