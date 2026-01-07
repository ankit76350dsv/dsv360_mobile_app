import 'package:flutter/material.dart';
import 'package:dsv360/views/profile/AboutMe.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Corporate Dark Theme Colors
    const kBackgroundColor = Color(0xFF121212); 
    const kCardColor = Color(0xFF1E1E1E);
    const kAccentColor = Color(0xFF00C853); // Corporate Green
    const kTextColor = Colors.white;
    const kSubTextColor = Colors.white70;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
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
                          kBackgroundColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Profile Avatar with Status
                Positioned(
                  bottom: -50,
                  left: 24, // Aligned left as per screenshot interpretation or design choice. Screenshot showed left alignment for info.
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
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
                            color: kAccentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: kBackgroundColor, width: 3),
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
                       const Text(
                          'Ankit Kumar',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: kAccentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kAccentColor.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: kAccentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildCompactActionButton('Password', Icons.lock_outline, kAccentColor),
                            _buildCompactActionButton('Edit', Icons.edit_outlined, kAccentColor),
                            // _buildCompactActionButton('Theme', Icons.palette_outlined, kAccentColor),
                          ],
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // About Me Section
                  const AboutMe(
                    title: 'About Me',
                    content: 'Admin Profile',
                    backgroundColor: kCardColor,
                    textColor: kTextColor,
                    accentColor: kAccentColor,
                  ),

                  const SizedBox(height: 24),

                  // Contact Information Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                             Container(
                               width: 4, height: 20,
                               decoration: BoxDecoration(color: kAccentColor, borderRadius: BorderRadius.circular(2)),
                             ),
                             const SizedBox(width: 8),
                             const Text(
                               'Contact Information',
                               style: TextStyle(
                                 color: kAccentColor,
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 20),
                         _buildContactRow(Icons.email_outlined, 'Email', 'aj637061@gmail.com', kSubTextColor),
                         const Divider(color: Colors.white10, height: 24),
                         _buildContactRow(Icons.phone_outlined, 'Phone', '+91 9984237401', kSubTextColor),
                         const Divider(color: Colors.white10, height: 24),
                         _buildContactRow(Icons.location_on_outlined, 'Address', 'Kanpur Nagar Uttar Pradesh', kSubTextColor),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Skills Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                             Container(
                               width: 4, height: 20,
                               decoration: BoxDecoration(color: kAccentColor, borderRadius: BorderRadius.circular(2)),
                             ),
                             const SizedBox(width: 8),
                             const Text(
                               'Skills',
                               style: TextStyle(
                                 color: kAccentColor,
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ],
                         ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildSkillChip('html', kSubTextColor),
                            _buildSkillChip('css', kSubTextColor),
                            _buildSkillChip('react', kSubTextColor),
                            _buildSkillChip('nodejs', kSubTextColor),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CV Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Update CV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View CV'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kAccentColor,
                        side: BorderSide(color: kAccentColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
    );
  }

  Widget _buildCompactActionButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
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

  Widget _buildContactRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00C853)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
        ),
      ),
    );
  }
}
