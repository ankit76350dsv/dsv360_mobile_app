import 'package:dsv360/core/constants/session_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:dsv360/views/profile/AboutMe.dart';
import 'package:dsv360/views/welcome/welcome_page.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/views/widgets/TopBar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthManager.instance.currentUser;
    final userProfile = UserManager.instance.userProfile;

    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    // final fullName = 'Ankit Kumar'.trim();
    final email = user?.emailId ?? 'No Email';
    // final email = user?.emailId ?? 'No Email';
    final role = user?.role?.name ?? 'User';

    // final fullName = 'Priya Malhotra';
    // final email = 'priya.malhotra@dsv360app.com';
    // final role = 'Operations Coordinator';
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- Header Section ---
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Background Image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                userProfile?.coverLink ??
                                    'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?auto=format&fit=crop&w=1000&q=80', // City Skyline
                              ),
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
                                  customColors.background!.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Profile Avatar with Status
                        Positioned(
                          bottom: -50,
                          left:
                              24, // Aligned left as per screenshot interpretation or design choice. Screenshot showed left alignment for info.
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: customColors.background,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                    userProfile?.profileLink ??
                                        'https://wallpapers.com/images/high/anonymous-hacker-theme-full-hd-h1g36h1m0iet2dih.webp',
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
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
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60), // Space for avatar
                    // --- User Info & Actions ---
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
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: customColors.statusCompleted!
                                            .withOpacity(0.5),
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
                                  //! Add them latter
                                  // _buildCompactActionButton(
                                  //   'Password',
                                  //   Icons.lock_outline,
                                  //   AppColors.statusCompleted,
                                  // ),
                                  // _buildCompactActionButton(
                                  //   'Edit',
                                  //   Icons.edit_outlined,
                                  //   AppColors.statusCompleted,
                                  // ),
                                  // _buildCompactActionButton('Theme', Icons.palette_outlined, AppColors.statusCompleted),
                                  //! Add them latter
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // About Me Section
                          AboutMe(
                            title: 'About Me',
                            content:
                                userProfile?.aboutMe ??
                                'No description available.',
                            // content:
                            //     'No description available.',
                            backgroundColor: customColors.cardBackground!,
                            textColor: customColors.textPrimary!,
                            accentColor: customColors.statusCompleted!,
                          ),

                          const SizedBox(height: 24),

                          // Contact Information Section
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

                                  // '+91 91234 56789',
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

                                  // '3rd Floor, Orion Business Hub, Andheri East, Mumbai, Maharashtra',
                                  customColors.textSecondary!,
                                  context,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Skills Section
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
                                // Dynamic Skills Parsing
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

                          // CV Actions
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: ElevatedButton.icon(
                          //     onPressed: () {},
                          //     icon: const Icon(Icons.cloud_upload_outlined),
                          //     label: const Text('Update CV'),
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: customColors.statusCompleted,
                          //       foregroundColor: Colors.black,
                          //       padding: const EdgeInsets.symmetric(
                          //         vertical: 16,
                          //       ),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(30),
                          //       ),
                          //       elevation: 0,
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 16),
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: OutlinedButton.icon(
                          //     onPressed: () {},
                          //     icon: const Icon(Icons.visibility_outlined),
                          //     label: const Text('View CV'),
                          //     style: OutlinedButton.styleFrom(
                          //       foregroundColor: customColors.statusCompleted,
                          //       side: BorderSide(
                          //         color: customColors.statusCompleted!,
                          //       ),
                          //       padding: const EdgeInsets.symmetric(
                          //         vertical: 16,
                          //       ),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(30),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // const SizedBox(height: 24),

                          // Logout Button
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
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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
        color: customColors.textWhite!.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: customColors.textWhite!.withOpacity(0.1)),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 13)),
    );
  }
}
