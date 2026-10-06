import 'package:flutter/material.dart';
import '../../glob/users.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  bool refreshing = false;
  int unreadCount = 0;

  final List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'type': 'appointment_reminder',
      'title': 'Upcoming appointment',
      'body': 'You have an upcoming Teeth Whitening appointment with Dr. Maria Santos.',
      'created_at': DateTime(2026, 10, 6, 18, 30),
      'is_read': false,
      'related_type': 'appointment',
      'related_id': 1,
    },
    {
      'id': 2,
      'type': 'message',
      'title': 'New message',
      'body': 'The clinic reception sent you a new message.',
      'created_at': DateTime(2026, 10, 6, 16, 20),
      'is_read': false,
      'related_type': 'message',
      'related_id': 1,
    },
    {
      'id': 3,
      'type': 'appointment_new',
      'title': 'Appointment confirmed',
      'body': 'Your dental appointment has been confirmed by the clinic.',
      'created_at': DateTime(2026, 10, 5, 10, 15),
      'is_read': true,
      'related_type': 'appointment',
      'related_id': 1,
    },
    {
      'id': 4,
      'type': 'recall',
      'title': 'Dental check-up reminder',
      'body': 'It may be time to schedule your next dental check-up.',
      'created_at': DateTime(2026, 10, 3, 9, 0),
      'is_read': true,
      'related_type': null,
      'related_id': null,
    },
  ];

  final Map<String, String> typeLabels = {
    'message': 'Message',
    'appointment_reminder': 'Appointment',
    'appointment_new': 'Appointment',
    'appointment_rescheduled': 'Appointment',
    'appointment_cancelled': 'Appointment',
    'appointment_cancelled_by_staff': 'Appointment',
    'recall': 'Recall',
    'system': 'System',
    'receipt_upload_enabled': 'Receipt',
    'receipt_validated': 'Receipt',
    'receipt_rejected': 'Receipt',
  };

  Map<String, dynamic> get currentUser {
    return AllUsers.currentUser ?? {'name': 'My Account', 'branchAddress': 'My Branch'};
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        fetchAll();
      }
    });
  }

  Future<void> fetchAll() async {
    if (!mounted) {
      return;
    }

    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    final int count = notifications.where((notification) => notification['is_read'] == false).length;

    setState(() {
      unreadCount = count;
      loading = false;
      refreshing = false;
    });
  }

  Future<void> onRefresh() async {
    if (!mounted) {
      return;
    }

    setState(() {
      refreshing = true;
    });

    await fetchAll();
  }

  Future<void> handleTap(Map<String, dynamic> notification) async {
    if (!mounted) {
      return;
    }

    if (notification['is_read'] == false) {
      setState(() {
        notification['is_read'] = true;
        unreadCount = notifications.where((item) => item['is_read'] == false).length;
      });
    }

    final String type = notification['type'].toString();
    final String? relatedType = notification['related_type']?.toString();
    final dynamic relatedId = notification['related_id'];

    String? route;
    Map<String, dynamic>? arguments;

    if (type == 'message' || relatedType == 'message') {
      route = '/messages-list';
    } else if (type == 'receipt_upload_enabled' || type == 'receipt_validated' || type == 'receipt_rejected') {
      route = '/appointments';
      arguments = {'highlightAppointmentId': relatedId};
    } else if (
      type == 'appointment_reminder' ||
      type == 'appointment_new' ||
      type == 'appointment_rescheduled' ||
      type == 'appointment_cancelled' ||
      type == 'appointment_cancelled_by_staff' ||
      relatedType == 'appointment'
    ) {
      route = '/appointments';
      arguments = {'highlightAppointmentId': relatedId};
    }

    if (route == null) {
      await fetchAll();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        route!,
        arguments: arguments,
      );
    });
  }

  Future<void> handleMarkAll() async {
    if (!mounted) {
      return;
    }

    setState(() {
      for (final notification in notifications) {
        notification['is_read'] = true;
      }

      unreadCount = 0;
    });

    await fetchAll();
  }

  String formatRelative(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  String getTypeLabel(String type) {
    return typeLabels[type] ?? type;
  }

  String getUserInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final List<String> parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length > 2 ? 2 : parts[0].length).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget header(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.073,
      padding: EdgeInsets.symmetric(horizontal: width * 0.045),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.09,
            height: height * 0.045,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Text(
                '☰',
                style: TextStyle(
                  fontSize: width * 0.07,
                  color: const Color(0xFFB47A00),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.w900,
                fontFamily: 'Georgia',
                color: const Color(0xFF1F1F1F),
              ),
            ),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: handleMarkAll,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: const Color(0xFFC88A11),
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SizedBox(width: width * 0.09),
        ],
      ),
    );
  }

  Widget unreadBar(BuildContext context) {
    if (unreadCount <= 0) {
      return const SizedBox.shrink();
    }

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.01,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF0),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8E0D0),
          ),
        ),
      ),
      child: Text(
        '$unreadCount unread',
        style: TextStyle(
          color: const Color(0xFFC88A11),
          fontSize: width * 0.033,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget notificationItem(BuildContext context, Map<String, dynamic> notification) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final bool isUnread = notification['is_read'] == false;
    final DateTime createdAt = notification['created_at'] as DateTime;
    final String type = notification['type'].toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          handleTap(notification);
        },
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.018,
          ),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFFFFBF0) : Colors.white,
            border: const Border(
              bottom: BorderSide(
                color: Color(0xFFE8E0D0),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread)
                Container(
                  width: width * 0.008,
                  height: height * 0.11,
                  margin: EdgeInsets.only(right: width * 0.025),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC88A11),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.015,
                        vertical: height * 0.0025,
                      ),
                      margin: EdgeInsets.only(
                        bottom: height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        getTypeLabel(type).toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFFB47A00),
                          fontSize: width * 0.025,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (notification['title'] != null && notification['title'].toString().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: height * 0.004,
                        ),
                        child: Text(
                          notification['title'].toString(),
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F1F1F),
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    Text(
                      notification['body'].toString(),
                      style: TextStyle(
                        fontSize: width * 0.032,
                        color: const Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: height * 0.008),
                    Text(
                      formatRelative(createdAt),
                      style: TextStyle(
                        fontSize: width * 0.027,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingContent(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.1),
        child: Text(
          'Loading...',
          style: TextStyle(
            color: const Color(0xFF999999),
            fontSize: width * 0.035,
          ),
        ),
      ),
    );
  }

  Widget emptyContent(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.1),
        child: Text(
          'No notifications yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF999999),
            fontSize: width * 0.035,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    bool active,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.pop(context);

          if (!active) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }

              Navigator.pushNamed(context, route);
            });
          }
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 42,
          ),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF8E7) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFFB47A00),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFB47A00),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sidebar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          36,
          20,
          28,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(right: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      getUserInitials(currentUser['name']),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFFB47A00),
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentUser['name'] ?? 'My Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFB47A00),
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(currentUser['branchAddress'] ?? 'My Branch',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A650E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 29,
              color: Color(0xFFE0E0E0),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  menuItem(context, Icons.home_outlined, 'Home', '/home', false),
                  menuItem(context, Icons.person_outline, 'Profile', '/profile', false),
                  menuItem(context, Icons.message_outlined, 'Message', '/messages-list', false),
                  menuItem(context, Icons.calendar_today_outlined, 'Appointments', '/appointments', false),
                  menuItem(context, Icons.folder_outlined, 'History', '/records', false),
                  menuItem(context, Icons.folder_copy_outlined, 'Treatment Plan', '/dental-treatment-plan', false),
                  menuItem(context, Icons.notifications_none, 'Notifications', '/notifications', true),
                ],
              ),
            ),
            const Divider(
              height: 29,
              color: Color(0xFFE0E0E0),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pop(context);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) {
                      return;
                    }

                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 42,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Color(0xFFB47A00)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Sign Out',
                          style: TextStyle(fontSize: 15, color: Color(0xFFB47A00), fontWeight: FontWeight.w700, fontFamily: 'Georgia'),
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      drawer: Drawer(
        backgroundColor: Colors.white,
        width: width * 0.9,
        child: sidebar(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (drawerContext) {
                return header(drawerContext);
              },
            ),
            unreadBar(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: loading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          loadingContent(context),
                        ],
                      )
                    : notifications.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              emptyContent(context),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return notificationItem(
                                context,
                                notifications[index],
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