import 'dart:math';
import 'package:dsv360/views/profile/AboutMe.dart';
import 'package:dsv360/views/profile/Badges.dart';
import 'package:dsv360/views/profile/InfoCard.dart';
import 'package:dsv360/views/profile/LabelValueText.dart';
import 'package:dsv360/views/profile/TagChip.dart';
import 'package:dsv360/views/widgets/ActionsButton.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Forest Theme Colors
    const kBackgroundColor = Color(0xFF0A2A0A); // Deep Forest Green
    // const kBackgroundColor = Colors.red; // Deep Forest Green
    const kSurfaceColor = Color(0xFFF5F5F5); // Crisp White/Grey
    // const kSurfaceColor = Colors.red; // Crisp White/Grey
    const kAccentColor = Color(0xFF1ED760); // Spotify/Bright Green

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Sliver App Bar ---
            SliverAppBar(
              // backgroundColor: Colors.transparent,
              backgroundColor: kBackgroundColor,
              elevation: 0,
              pinned: true,
              // expandedHeight: 60.0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // --- Profile Header (Avatar + Info) ---
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, kSurfaceColor),
            ),

            // --- Content Body (Rounded Top) ---
            SliverToBoxAdapter(
              child: Container(
                constraints: const BoxConstraints(minHeight: 500),
                decoration: const BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Me
                      const AboutMe(
                        title: 'About Me',
                        content:
                            'Full-stack developer passionate about building clean, scalable apps and delightful UX.',
                        accentColor: Color(0xFF0F3D0F),
                      ),
                      const SizedBox(height: 24),

                      // Stats Grid
                      _buildStatsGrid(context),
                      const SizedBox(height: 24),

                      // Badges
                      const BadgesSection(
                        title: 'Badges',
                        accentColor: Color(0xFF0F3D0F),
                        badges: [
                          BadgeChip(label: 'BFSI - Bronze', chipColor: Color(0xFFB66D2F)),
                          BadgeChip(label: 'RETAIL - Titanium', chipColor: Color(0xFF7A2CE6)),
                          BadgeChip(label: 'BFSI - Diamond', chipColor: Color(0xFF2AB2F2)),
                          BadgeChip(label: 'Innovation - Gold', chipColor: Color(0xFFDAA520)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Skills
                      const Text(
                        "Skills",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          TagChip(
                            label: 'NodeJs',
                            gradientColors: [Color(0xFF215732), Color(0xFF6CC24A)],
                          ),
                          TagChip(
                            label: 'ReactJs',
                            gradientColors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          ),
                          TagChip(
                            label: 'MongoDB',
                            gradientColors: [Color(0xFF13aa52), Color(0xFF00ed64)],
                          ),
                          TagChip(
                            label: 'Flutter',
                            gradientColors: [Color(0xFF02569B), Color(0xFF0175C2)],
                          ),
                          TagChip(
                            label: 'AWS',
                            gradientColors: [Color(0xFFFF9900), Color(0xFFFFC300)],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ActionsButton(
                              label: 'Upload CV',
                              icon: Icons.cloud_upload_outlined,
                              type: ActionButtonType.filled,
                              filledBackgroundColor: Colors.black,
                              filledTextColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ActionsButton(
                              label: 'View CV',
                              icon: Icons.visibility_outlined,
                              type: ActionButtonType.filled,
                              filledBackgroundColor: Colors.white,
                              filledTextColor: Colors.black,
                              filledBorderColor: Colors.black12,
                            ),
                          ),
                        ],
                      ),
                      
                      // Bottom Padding
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
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

  Widget _buildProfileHeader(BuildContext context, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          // Avatar Cluster
          Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Glow/Shadow effect
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1ED760).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Avatar
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
                  ),
                  backgroundColor: Colors.grey,
                ),
                // Edit Icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Color(0xFF0F3D0F)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Name & Actions
          Column(
            children: [
              const Text(
                'Ankit Kumar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ankit@dsvcorp.com.au',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              
              // Contact Details - Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_iphone, size: 16, color: Color(0xFF1ED760)),
                    const SizedBox(width: 8),
                    const Text(
                      "+91-7635046798",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 1, height: 16, color: Colors.white24),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF1ED760)),
                    const SizedBox(width: 8),
                    const Text(
                      "The Social Street S.NO. 32, Main Hinjawadi- Wakad Road, 411057, Hinjawadi, Pune, Maharashtra 411057",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: const InfoCard(
                leadingIcon: Icons.emoji_events_rounded,
                title: 'Top 1%',
                subtitle: 'Performer',
                iconBgColor: Color(0xFFFFF8E1),
                iconColor: Color(0xFFFFB300),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: const InfoCard(
                leadingIcon: Icons.auto_awesome_rounded,
                title: '51',
                subtitle: 'Skill Badges',
                iconBgColor: Color(0xFFE8F5E9),
                iconColor: Color(0xFF43A047),
              ),
            ),
          ],
        );
      },
    );
  }
}
