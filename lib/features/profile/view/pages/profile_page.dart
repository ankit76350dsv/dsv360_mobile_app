import 'package:dsv360/core/constants/session_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/profile/view/widgets/profile_crop_image_page.dart';
import 'package:dsv360/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/features/profile/view/widgets/about_me.dart';
import 'package:dsv360/views/welcome/welcome_page.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isUploading = false;
  bool _isBannerUploading = false;
  String? _profileImageUrl;
  String? _bannerImageUrl;

  ProfileViewModel get _viewModel => ref.read(profileViewModelProvider);

  @override
  void initState() {
    super.initState();
    final userProfile = UserManager.instance.userProfile;
    _profileImageUrl = userProfile?.profileLink;
    _bannerImageUrl = userProfile?.coverLink;
  }

  Future<String> _resolveUserId() async {
    return _viewModel.resolveUserId();
  }

  Future<void> _refreshProfileAndSyncImages(String userId) async {
    final refreshed = await _viewModel.fetchUserProfile(userId);
    if (!mounted || refreshed == null) return;

    setState(() {
      if (refreshed.profileLink.isNotEmpty) {
        _profileImageUrl = refreshed.profileLink;
      }
      if (refreshed.coverLink.isNotEmpty) {
        _bannerImageUrl = refreshed.coverLink;
      }
    });
  }

  /// Crops the profile image
  Future<File?> _cropImage(File imageFile) async {
    return await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (context) => CropImagePage(imageFile: imageFile),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        debugPrint('📸 No image selected');
        return;
      }

      if (!mounted) return;

      debugPrint('📸 Image selected: ${image.name} (${image.path})');

      // --- Crop the selected image before uploading ---
      final croppedFile = await _cropImage(File(image.path));
      if (croppedFile == null) {
        debugPrint('✂️ Crop cancelled by user');
        return;
      }

      if (!mounted) return;

      debugPrint('✂️ Cropped image path: ${croppedFile.path}');
      // -------------------------------------------------

      setState(() => _isUploading = true);

      final userId = await _resolveUserId();

      debugPrint('👤 Uploading for user ID: $userId');

      debugPrint('📤 Sending FormData to server...');

      // Upload to server
      final response = await _viewModel.uploadProfileImage(
        userId: userId,
        croppedFile: croppedFile,
        filename: image.name,
      );

      debugPrint('✅ Upload response: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (mounted) {
        final responseUrl = (response.data is Map)
            ? (response.data['profileURL'] ?? '').toString()
            : '';
        setState(() {
          _profileImageUrl = responseUrl.isNotEmpty ? responseUrl : croppedFile.path;
        });

        await _refreshProfileAndSyncImages(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      debugPrint('Stack: ${StackTrace.current}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Upload failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickAndUploadBannerImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        debugPrint('📸 No banner selected');
        return;
      }

      debugPrint('🖼️ Banner selected: ${image.name}');
      setState(() => _isBannerUploading = true);
      final userId = await _resolveUserId();

      final response = await _viewModel.uploadBannerImage(
        userId: userId,
        imagePath: image.path,
        filename: image.name,
      );
      debugPrint('Banner upload response: ${response.data}');

      if (mounted) {
        final responseCoverUrl = (response.data is Map)
            ? (response.data['coverURL'] ?? '').toString()
            : '';
        setState(() {
          _bannerImageUrl = responseCoverUrl.isNotEmpty
              ? responseCoverUrl
              : image.path;
        });

        await _refreshProfileAndSyncImages(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banner image updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Banner upload error: $e');
      debugPrint('Stack: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Banner upload failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBannerUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthManager.instance.currentUser;
    final userProfile = UserManager.instance.userProfile;

    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final email = user?.emailId ?? 'No Email';
    final role = user?.role?.name ?? 'User';

    debugPrint(
      '👤 👤 👤 👤 👤 👤 👤 👤 👤 👤 Building ProfilePage for user: ${userProfile?.skills}',
    );

    final customColors = Theme.of(context).custom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(title: 'Profile', onBack: () => Navigator.pop(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async{
                  final userId = await _resolveUserId();
                   await _refreshProfileAndSyncImages(userId);
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Header Section ---
                      SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Background Image
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: _bannerImageUrl != null
                                        ? (_bannerImageUrl!.startsWith('http')
                                            ? NetworkImage(_bannerImageUrl!)
                                            : FileImage(File(_bannerImageUrl!)))
                                            as ImageProvider
                                        : (userProfile?.coverLink != null
                                            ? NetworkImage(userProfile!.coverLink)
                                            : const AssetImage('assets/images/banner.jpg')
                                                as ImageProvider),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        customColors.background!.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: (_isUploading || _isBannerUploading)
                                      ? null
                                      : _pickAndUploadBannerImage,
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        width: 1,
                                      ),
                                    ),
                                    child: _isBannerUploading
                                        ? const Padding(
                                            padding: EdgeInsets.all(9),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                
                            // Profile Avatar with clickable image area
                            Positioned(
                              top: 145,
                              left: 24,
                              child: SizedBox(
                                width: 116,
                                height: 116,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _isUploading ? null : _pickAndUploadImage,
                                        customBorder: const CircleBorder(),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: customColors.background,
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage: _profileImageUrl != null
                                                ? (_profileImageUrl!.startsWith('http')
                                                    ? NetworkImage(_profileImageUrl!)
                                                    : FileImage(File(_profileImageUrl!)))
                                                    as ImageProvider
                                                : (userProfile?.profileLink != null
                                                    ? NetworkImage(userProfile!.profileLink)
                                                    : const AssetImage('assets/images/profile.jpg')
                                                        as ImageProvider),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      right: 10,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: customColors.statusCompleted,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: customColors.background!,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _isUploading ? null : _pickAndUploadImage,
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: customColors.primary,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: _isUploading
                                                ? const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<Color>(
                                                        Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName.isNotEmpty ? fullName : 'User',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: customColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: customColors.statusCompleted!
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: customColors.statusCompleted!
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        role.isNotEmpty ? role : 'User',
                                        style: TextStyle(
                                          color: customColors.statusCompleted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                
                            const SizedBox(height: 24),
                
                            AboutMe(
                              title: 'About Me',
                              content:
                                  userProfile?.aboutMe ??
                                  'No description available.',
                              backgroundColor: customColors.cardBackground!,
                              textColor: customColors.textPrimary!,
                              accentColor: customColors.statusCompleted!,
                            ),
                
                            const SizedBox(height: 24),
                
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: customColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: customColors.statusCompleted,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Contact Information',
                                        style: TextStyle(
                                          color: customColors.statusCompleted,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildContactRow(
                                    Icons.email_outlined,
                                    'Email',
                                    email,
                                    customColors.textSecondary!,
                                    context,
                                  ),
                                  Divider(
                                    color: customColors.divider,
                                    height: 24,
                                  ),
                                  _buildContactRow(
                                    Icons.phone_outlined,
                                    'Phone',
                                    userProfile?.phone ??
                                        'No Phone details available.',
                                    customColors.textSecondary!,
                                    context,
                                  ),
                                  Divider(
                                    color: customColors.divider,
                                    height: 24,
                                  ),
                                  _buildContactRow(
                                    Icons.location_on_outlined,
                                    'Address',
                                    userProfile?.address ??
                                        'No Address available.',
                                    customColors.textSecondary!,
                                    context,
                                  ),
                                ],
                              ),
                            ),
                
                            const SizedBox(height: 24),
                
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: customColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: customColors.statusCompleted,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Skills',
                                        style: TextStyle(
                                          color: customColors.statusCompleted,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (userProfile?.skills != null &&
                                      userProfile!.skills.isNotEmpty)
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children:
                                          (userProfile.skills.contains(',')
                                                  ? userProfile.skills.split(',')
                                                  : [userProfile.skills])
                                              .map(
                                                (skill) => _buildSkillChip(
                                                  skill.trim(),
                                                  customColors.textSecondary!,
                                                  context,
                                                ),
                                              )
                                              .toList(),
                                    )
                                  else
                                    Text(
                                      'No skills added yet.',
                                      style: TextStyle(
                                        color: customColors.textHint,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                
                            const SizedBox(height: 32),
                
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final confirmed =
                                      await showWarningDialogueBox<bool>(
                                        context: context,
                                        title: 'You will be logged out',
                                        subtitle:
                                            'Are you sure you want to logout?',
                                        primaryText: 'Logout',
                                        onPrimaryPressed: (dialogContext) =>
                                            Navigator.of(dialogContext).pop(true),
                                      );
                
                                  if (confirmed != true) return;
                
                                  await SessionManager.logout(context);
                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const WelcomePage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: customColors.error,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    BuildContext context,
  ) {
    final customColors = Theme.of(context).custom;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: customColors.statusCompleted),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: textColor, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color textColor, BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: customColors.textWhite!.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: customColors.textWhite!.withValues(alpha: 0.01)),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 13)),
    );
  }
}