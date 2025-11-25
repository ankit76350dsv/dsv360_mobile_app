// lib/main.dart
import 'dart:math';
import 'package:dsv360/views/profile/AboutMe.dart';
import 'package:dsv360/views/profile/Badges.dart';
import 'package:dsv360/views/profile/InfoCard.dart';
import 'package:dsv360/views/profile/LabelValueText.dart';
import 'package:dsv360/views/profile/TagChip.dart';
import 'package:dsv360/views/widgets/ActionsButton.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // overall screen size
    final media = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 64, // choose actual TopBar height
                child: TopBar(
                  title: 'Profile',
                  onBack: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  onInfoTap: () {},
                ),
              ),
            ),

            // TopBar(
            //   title: 'Profile',
            //   onBack: () {
            //     // for demo: pop if possible, otherwise do nothing
            //     if (Navigator.canPop(context)) {
            //       Navigator.pop(context);
            //     }
            //   },
            //   onInfoTap: () {
            //     // hook for info action
            //     // you can open a dialog or screen here
            //   },
            // ),

            // Replace the Positioned.fill -> SingleChildScrollView ... LayoutBuilder block
            // in your
            Positioned.fill(
              top: media.height * 0.09,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // adaptive sizes
                  final avatarRadius = min(48.0, constraints.maxWidth * 0.11);
                  final gridAspect = constraints.maxWidth > 420 ? 2.1 : 1.9;

                  return SingleChildScrollView(
                    // keep scrollable if the whole page needs to scroll on small screens
                    child: SizedBox(
                      // key change: force the inner Column to be exactly the viewport height,
                      // so Expanded can fill remaining space without IntrinsicHeight.
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          // --- Replace the existing Stack(...) block with this ---
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                  18,
                                  avatarRadius +
                                      16, // SHIFT TEXT DOWN BELOW AVATAR
                                  16,
                                  16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    220,
                                    219,
                                    219,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name + email only (friends button removed from here)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Ankit Kumar',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                'ankit@dsvcorp.com.au',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // stats row (removed Record pill from here)
                                    Row(
                                      children: [
                                        LabelValueText(
                                          label: "Ph. No.",
                                          value: "+91-7635046798",
                                          charLimit: 125,
                                          enableToolkit: true,
                                          toolkitIcon: Icons.phone_iphone,
                                        ),

                                        SizedBox(width: 12.0),
                                        LabelValueText(
                                          label: "Addr.",
                                          value:
                                              'The Social Street S.NO. 32, Main Hinjawadi - Wakad Road, 411057, Hinjawadi, Pune, Maharashtra 411057',
                                          charLimit:
                                              15, // inline truncated text; popover shows full value
                                          enableToolkit: true,
                                          toolkitIcon: Icons.check_circle,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Avatar (same as before)
                              Positioned(
                                left: 16,
                                top: -avatarRadius * 0.9,
                                child: CircleAvatar(
                                  radius: avatarRadius + 4,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: avatarRadius,
                                    backgroundImage: const NetworkImage(
                                      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
                                    ),
                                  ),
                                ),
                              ),

                              // NEW: place +Friends and Record SIDE BY SIDE on the right
                              Positioned(
                                right: 16,
                                top:
                                    avatarRadius *
                                    0.4, // adjust vertical alignment
                                child: Row(
                                  children: const [
                                    ActionsButton(
                                      label: 'Change Password',
                                      icon: Icons.password_rounded,
                                    ),
                                    SizedBox(width: 5),
                                    ActionsButton(
                                      label: 'Edit Profile',
                                      icon: Icons.edit,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // --- REPLACE your current Expanded(...) block with this ---
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: const Color.fromARGB(255, 220, 219, 219),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                20,
                              ),
                              // Use a Column so we can put Grid + Upload button one after another
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AboutMe(
                                    title: 'About Me',
                                    content:
                                        'Full-stack developer passionate about building clean, scalable apps and delightful UX.',
                                  ),
                                  // The grid (shrinkWrap so it only takes needed height)
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: gridAspect,
                                    children: const [
                                      InfoCard(
                                        leadingIcon: Icons.star,
                                        title: '51',
                                        subtitle: 'Balance',
                                        iconBgColor: Color(0xFFFFF5E6),
                                        iconColor: Color(0xFFF2B84A),
                                      ),
                                      InfoCard(
                                        leadingIcon: Icons.emoji_events,
                                        title: '1',
                                        subtitle: 'Batch',
                                        iconBgColor: Color(0xFFFFF5E6),
                                        iconColor: Color(0xFFF2B84A),
                                      ),
                                    ],
                                  ),

                                  // small spacer between grid and button
                                  const SizedBox(height: 18),

                                  // import 'badges_section.dart';
                                  BadgesSection(
                                    title: 'Badges',
                                    badges: const [
                                      BadgeChip(
                                        label: 'BFSI - Bronze',
                                        chipColor: Color(0xFFB66D2F),
                                      ),
                                      BadgeChip(
                                        label: 'RETAIL - Titanium',
                                        chipColor: Color(0xFF7A2CE6),
                                      ),
                                      BadgeChip(
                                        label: 'BFSI - Diamond',
                                        chipColor: Color(0xFF2AB2F2),
                                      ),
                                      BadgeChip(
                                        label: 'Test_Badges - Titanium',
                                        chipColor: Color(0xFF7A2CE6),
                                      ),
                                      // add more...
                                    ],
                                  ),

                                  // small spacer between grid and button
                                  const SizedBox(height: 18),
                                  Text("Skils"),

                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 8,
                                    children: const [
                                      TagChip(
                                        label: 'NodeJs',
                                        gradientColors: [
                                          Color(0xFF85F1FF),
                                          Color(0xFF8EB0FF),
                                        ],
                                      ),
                                      TagChip(
                                        label: 'ReactJs',
                                        gradientColors: [
                                          Color(0xFFFFA8C5),
                                          Color(0xFFFF6B8A),
                                        ],
                                      ),
                                      TagChip(
                                        label: 'MongoDB',
                                        gradientColors: [
                                          Color(0xFFFFC77D),
                                          Color(0xFFFF7A7A),
                                        ],
                                      ),
                                      TagChip(
                                        label: 'S3 Bucket',
                                        gradientColors: [
                                          Color(0xFFB39AFF),
                                          Color(0xFF6D5BFC),
                                        ],
                                      ),
                                      TagChip(
                                        label: 'AWS',
                                        gradientColors: [
                                          Color(0xFF9AE6B4),
                                          Color(0xFF55C57B),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Centered upload button just after the last grid item
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ActionsButton(
                                          label: 'Upload CV',
                                          icon: Icons.cloud_upload,
                                          type: ActionButtonType.filled,
                                          onTap: () {},
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ), // spacing between buttons
                                        ActionsButton(
                                          label: 'View CV',
                                          icon: Icons.cloud_upload,
                                          type: ActionButtonType.tag,
                                          onTap: () {},
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Keep some bottom spacing so button isn't touching the bottom of the card
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
