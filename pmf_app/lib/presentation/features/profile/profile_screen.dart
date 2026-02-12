import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pmf_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/data/models/profile_model.dart';
import 'package:pmf_app/presentation/shared/neumorphic_container.dart';
import '../../../bloc/profile_bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'English';
  bool _isDarkMode = true;
  bool _isNotificationsEnabled = true;
  final List<String> _availableAvatars = const [
    'assets/avatars/avatar1.jpg',
    'assets/avatars/avatar2.jpg',
    'assets/avatars/avatar3.jpg',
    'assets/avatars/avatar4.jpg',
    'assets/avatars/avatar5.jpg',
    'assets/avatars/avatar6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[ProfileScreen] Loading profile...');
      context.read<ProfileBloc>().add(LoadProfile());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (state is ProfileLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  )
                else if (state is ProfileLoaded)
                  Column(
                    children: [
                      _buildProfileHeader(
                        state.profile.displayName,
                        state.profile.avatarUrl,
                        onEdit: () => _showEditProfileModal(state.profile),
                      ),
                      const SizedBox(height: 30),
                      _buildSettingsSection(),
                      const SizedBox(height: 30),
                      _buildLogoutButton(context),
                    ],
                  )
                else if (state is ProfileError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading profile',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              context.read<ProfileBloc>().add(LoadProfile());
                            },
                            child: NeumorphicContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: AppColors.primaryEmerald,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      _buildProfileHeader('User', ''),
                      const SizedBox(height: 30),
                      _buildSettingsSection(),
                      const SizedBox(height: 30),
                      _buildLogoutButton(context),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    String displayName,
    String? avatarUrl, {
    VoidCallback? onEdit,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryEmerald.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primaryEmerald.withOpacity(0.2),
              backgroundImage: _getAvatarImage(avatarUrl),
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryEmerald,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // User name
          Text(
            displayName.isNotEmpty ? displayName : 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 4),
          if (onEdit != null)
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16, color: AppColors.primaryEmerald),
              label: const Text(
                'Edit Profile',
                style: TextStyle(color: AppColors.primaryEmerald, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }
    if (avatarUrl.contains('http')) {
      return NetworkImage(avatarUrl);
    }
    return AssetImage(avatarUrl);
  }

  void _showEditProfileModal(ProfileModel profile) {
    final controller = TextEditingController(text: profile.displayName);
    String selectedAvatar = profile.avatarUrl?.isNotEmpty == true
        ? profile.avatarUrl!
        : _availableAvatars.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.mintLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.navyDark),
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  labelStyle: const TextStyle(color: AppColors.navyDark),
                  filled: true,
                  fillColor: AppColors.secondaryEmerald,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Avatar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableAvatars
                    .map(
                      (avatar) => _buildAvatarOption(
                        avatar,
                        isSelected: selectedAvatar == avatar,
                        onTap: () {
                          setModalState(() {
                            selectedAvatar = avatar;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.navyDark),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Display name cannot be empty')),
                          );
                          return;
                        }
                        context.read<ProfileBloc>().add(UpdateProfile(name, selectedAvatar));
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
    String avatarPath, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundImage: AssetImage(avatarPath),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Settings'),
        _buildLanguageDropdown(),
        const SizedBox(height: 12),
        _buildToggleItem(
          Icons.dark_mode_outlined,
          'Dark Mode',
          _isDarkMode,
          (value) {
            setState(() {
              _isDarkMode = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildToggleItem(
          Icons.notifications_outlined,
          'Notifications',
          _isNotificationsEnabled,
          (value) {
            setState(() {
              _isNotificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return GestureDetector(
      onTap: () {
        _showLanguageModal();
      },
      child: NeumorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.language_outlined, color: AppColors.primaryEmerald, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(fontSize: 14, color: AppColors.navyDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLanguage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mintLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption('English'),
            _buildLanguageOption('Tiếng Việt'),
            _buildLanguageOption('中文'),
            _buildLanguageOption('日本語'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primaryEmerald.withOpacity(0.2) : AppColors.secondaryEmerald,
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.primaryEmerald : AppColors.navyDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryEmerald,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryEmerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.navyDark),
            ),
          ),
          GestureDetector(
            onTap: () {
              onChanged(!value);
            },
            child: Container(
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value ? AppColors.primaryEmerald : Colors.grey.shade700,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: value ? 24 : 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog(context);
      },
      child: NeumorphicContainer(
        isConvex: false,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: Text(
            'Logout',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.mintLight,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.navyDark),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.navyDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primaryEmerald),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}