import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/users/user_details_page.dart';
import 'package:dsv360/views/widgets/VerificationStatusChip.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final theme = Theme.of(context);

    final users = <UsersModel>[
      UsersModel(
        name: "Aman Jain",
        userId: "U5367",
        emailAddress: "aman.jain@example.com",
        role: "Admin",
        workStatus: WorkStatus.active,
        verificationStatus: VerificationStatus.verified,
      ),
      UsersModel(
        name: "adsadas Patel",
        userId: "U4243",
        emailAddress: "adsadas.patel@example.com",
        role: "Intern",
        workStatus: WorkStatus.resigned,
        verificationStatus: VerificationStatus.pending,
      ),
      UsersModel(
        name: "Kaushal Kishor",
        userId: "U1227",
        emailAddress: "kaushal.kishor@example.com",
        role: "Manager/Team Lead",
        workStatus: WorkStatus.active,
        verificationStatus: VerificationStatus.verified,
      ),
      UsersModel(
        name: "Employee Singh",
        userId: "U3172",
        emailAddress: "employee.singh@example.com",
        role: "Intern",
        workStatus: WorkStatus.active,
        verificationStatus: VerificationStatus.verified,
      ),
      UsersModel(
        name: "abhay",
        userId: "U4167",
        emailAddress: "abhay@example.com",
        role: "Manager/Team Lead",
        workStatus: WorkStatus.left,
        verificationStatus: VerificationStatus.pending,
      ),
      UsersModel(
        name: "Ujjwal Mishra",
        userId: "U4027",
        emailAddress: "ujjwal.mishra@example.com",
        role: "Business Analyst",
        workStatus: WorkStatus.active,
        verificationStatus: VerificationStatus.verified,
      ),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('DSV-360'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white12,
            child: const Icon(Icons.person_outline, size: 18),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: UserCard(user: users[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;

  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.successDark, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people,
                  color: isDark ? Colors.black : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Users",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "Search Users",
              filled: true,
              fillColor: Colors.black.withOpacity(0.25),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UsersModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsPage(user: user)),
        );
      },
      child: Container(
        height: 150.00,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.primary.withOpacity(0.15),
                    child: const Icon(Icons.person, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(user.userId, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _RoleChip(text: user.role),
                VerificationStatusChip(status: user.verificationStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String text;

  const _RoleChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 14)),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
