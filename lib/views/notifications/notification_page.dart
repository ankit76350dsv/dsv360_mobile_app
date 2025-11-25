import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:flutter/material.dart';


class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0D),
        cardColor: const Color(0xFF0F1113),
      ),
      home: const NotificationListWithTopBarPage(),
    );
  }
}

class NotificationListWithTopBarPage extends StatelessWidget {
  const NotificationListWithTopBarPage({super.key});

  final double horizontalPadding = 14;

  // demo data (same items as before)
  List<NotificationItem> _items() => [
        NotificationItem.logo(
          tag: 'Leave Approved',
          title: 'Your casual leave request for 12 Nov has been approved',
          subtitle: 'By HR Team',
          logoText: 'L',
          logoColor: Colors.green,
        ),
        NotificationItem.logo(
          tag: 'Leave Rejected',
          title: 'Your sick leave request for 10 Nov has been rejected',
          subtitle: 'Reason: Insufficient leave balance',
          logoText: 'L',
          logoColor: Colors.red,
        ),
        NotificationItem.avatar(
          title:
              'Manager Priya Sharma assigned you a new task: “Prepare Monthly Report”.',
          avatarUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
        ),
        NotificationItem.check(
          tag: 'Attendance Verified',
          title: 'Your attendance for today has been successfully marked.',
        ),
        NotificationItem.avatar(
          title:
              'HR posted a new announcement: "Office will remain closed on Friday due to maintenance."',
        ),
        NotificationItem.logo(
          tag: 'Payroll Update',
          title: 'Your salary slip for October is now available.',
          subtitle: 'Open the Payroll section to download.',
          logoText: 'P',
          logoColor: Colors.blue,
        ),
        NotificationItem.logo(
          tag: 'Meeting Reminder',
          title: 'You have a scheduled meeting with HR at 3:00 PM today.',
          subtitle: 'Performance Review Discussion',
          logoText: 'M',
          logoColor: Colors.purple,
        ),
        NotificationItem.avatar(
          title: 'Team Lead Rahul Verma shared a new project update.',
          avatarUrl:
              'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200&h=200&fit=crop',
        ),
        NotificationItem.check(
          tag: 'Training Completed',
          title: 'Congratulations! You completed the mandatory Cyber Security Training.',
        ),
        NotificationItem.logo(
          tag: 'Shift Update',
          title: 'Your shift for this weekend has been updated.',
          subtitle: 'New Shift: 10 AM – 6 PM',
          logoText: 'S',
          logoColor: Colors.orange,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // ---------- Top bar ----------
                TopBar(
                  title: 'Notification',
                  onBack: () {
                    // for demo: pop if possible, otherwise do nothing
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  onInfoTap: () {
                    // hook for info action
                    // you can open a dialog or screen here
                  },
                ),

                // ---------- Notifications list only ----------
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 18, bottom: 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _NotificationCard(item: items[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// --- Models ---
enum LeadingType { avatar, logo, check }

class NotificationItem {
  final String tag;
  final String title;
  final String subtitle;
  final LeadingType leadingType;
  final String? avatarUrl;
  final String? logoText;
  final Color? logoColor;

  NotificationItem._({
    this.tag = '',
    required this.title,
    this.subtitle = '',
    required this.leadingType,
    this.avatarUrl,
    this.logoText,
    this.logoColor,
  });

  factory NotificationItem.avatar({
    String tag = '',
    required String title,
    String subtitle = '',
    String? avatarUrl,
  }) =>
      NotificationItem._(
        tag: tag,
        title: title,
        subtitle: subtitle,
        leadingType: LeadingType.avatar,
        avatarUrl: avatarUrl,
      );

  factory NotificationItem.logo({
    String tag = '',
    required String title,
    String subtitle = '',
    required String logoText,
    required Color logoColor,
  }) =>
      NotificationItem._(
        tag: tag,
        title: title,
        subtitle: subtitle,
        leadingType: LeadingType.logo,
        logoText: logoText,
        logoColor: logoColor,
      );

  factory NotificationItem.check({
    String tag = '',
    required String title,
    String subtitle = '',
  }) =>
      NotificationItem._(
        tag: tag,
        title: title,
        subtitle: subtitle,
        leadingType: LeadingType.check,
      );
}

/// --- Card widget (keeps styling identical to your screenshot) ---
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1113),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _leading(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.tag.isNotEmpty) ...[
                    _tagChip(item),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _leading() {
    switch (item.leadingType) {
      case LeadingType.logo:
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.logoColor ?? Colors.grey,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            item.logoText ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      case LeadingType.check:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF0B1220),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Color(0xFF24C16E)),
        );
      case LeadingType.avatar:
        return CircleAvatar(
          radius: 22,
          backgroundImage:
              item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
          backgroundColor: const Color(0xFF2A2A2A),
          child: item.avatarUrl == null
              ? const Icon(Icons.person, color: Colors.white54)
              : null,
        );
    }
  }

  // NEW: color tags by context (tag + title + subtitle)
  Widget _tagChip(NotificationItem item) {
    final text = '${item.tag} ${item.title} ${item.subtitle}'.toLowerCase();
    final bg = _chipColorFromContent(text, item.leadingType);
    final fg = _textColorForBg(bg);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        item.tag,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  // choose a background color from keywords (checks the combined content)
  Color _chipColorFromContent(String content, LeadingType leadingType) {
    // priority-based checks
    if (content.contains('approved') || content.contains('verified') || content.contains('success') || content.contains('completed')) {
      return const Color(0xFF16A34A); // green
    }
    if (content.contains('rejected') || content.contains('reject') || content.contains('insufficient') || content.contains('failed') || content.contains('declined')) {
      return const Color(0xFFEF4444); // red
    }
    if (content.contains('pay') || content.contains('salary') || content.contains('payroll') || content.contains('slip')) {
      return const Color(0xFF2563EB); // blue
    }
    if (content.contains('meeting') || content.contains('reminder') || content.contains('schedule') || content.contains('calendar')) {
      return const Color(0xFF7C3AED); // purple
    }
    if (content.contains('shift') || content.contains('roster') || content.contains('timing')) {
      return const Color(0xFFF97316); // orange
    }
    if (content.contains('training') || content.contains('course') || content.contains('learning')) {
      return const Color(0xFF0EA5A0); // teal
    }
    if (content.contains('holiday') || content.contains('closed') || content.contains('announcement')) {
      return const Color(0xFF0891B2); // cyan-ish
    }
    if (content.contains('task') || content.contains('assigned') || content.contains('todo') || content.contains('update') || content.contains('project')) {
      return const Color(0xFFF59E0B); // amber
    }
    if (content.contains('attendance') || content.contains('present') || content.contains('absent')) {
      return const Color(0xFF0EA94C); // slightly different green
    }
    if (content.contains('urgent') || content.contains('important') || content.contains('action required')) {
      return const Color(0xFFDC2626); // darker red
    }

    // fallback: base on leading type to give visual variety
    switch (leadingType) {
      case LeadingType.logo:
        return const Color(0xFF374151); // slate/grey
      case LeadingType.check:
        return const Color(0xFF10B981); // green-ish
      case LeadingType.avatar:
        return const Color(0xFF4B5563); // neutral grey
    }
  }

  // pick readable text color for a background
  Color _textColorForBg(Color bg) {
    // use computeLuminance: > 0.5 is "light" -> use dark text
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
