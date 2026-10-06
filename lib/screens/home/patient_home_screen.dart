import 'package:flutter/material.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => PatientHomeScreenState();
}

class PatientHomeScreenState extends State<PatientHomeScreen> {
  Map<String, dynamic>? currentUser;

  bool loading = true;
  bool refreshing = false;

  int unreadCount = 2;

  List<Map<String, dynamic>> appointments = [
    {
      'id': 1,
      'service_name': 'Teeth Whitening',
      'dentist_name': 'Dr. Maria Santos',
      'branch_name': 'Makati City',
      'start_time': DateTime(2026, 10, 10, 10, 0),
      'status': 'scheduled',
    },
    {
      'id': 2,
      'service_name': 'Deep Scaling',
      'dentist_name': 'Dr. John Cruz',
      'branch_name': 'Makati City',
      'start_time': DateTime(2026, 9, 25, 14, 0),
      'status': 'completed',
    },
    {
      'id': 3,
      'service_name': 'Dental Consultation',
      'dentist_name': 'Dr. Angela Reyes',
      'branch_name': 'Quezon City',
      'start_time': DateTime(2026, 9, 15, 9, 30),
      'status': 'cancelled',
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        loadData();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      currentUser = args;
    }
  }

  Future<void> loadData() async {
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

    setState(() {
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

    await loadData();
  }

  String getUserName() {
    final String? name = currentUser?['name']?.toString().trim();

    if (name == null || name.isEmpty) {
      return 'there';
    }

    return name;
  }

  String getUserEmail() {
    final String? email = currentUser?['email']?.toString().trim();

    if (email == null || email.isEmpty) {
      return '';
    }

    return email;
  }

  String formatRelativeDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime appointmentDate = DateTime(date.year, date.month, date.day);
    final int difference = appointmentDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Tomorrow';
    }

    if (difference == -1) {
      return 'Yesterday';
    }

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatTimeOnly(DateTime date) {
    final int hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  bool isCancellationLocked(Map<String, dynamic> appointment) {
    final dynamic startTime = appointment['start_time'];

    if (startTime is! DateTime) {
      return true;
    }

    final Duration difference = startTime.difference(DateTime.now());

    return difference.inHours < 24;
  }

  List<Map<String, dynamic>> get upcoming {
    final DateTime now = DateTime.now();

    return appointments.where((appointment) {
      final dynamic startTime = appointment['start_time'];

      return appointment['status'] == 'scheduled' &&
          startTime is DateTime &&
          !startTime.isBefore(now);
    }).toList();
  }

  List<Map<String, dynamic>> get past {
    final DateTime now = DateTime.now();

    final List<Map<String, dynamic>> result = appointments.where((appointment) {
      final dynamic startTime = appointment['start_time'];

      return appointment['status'] != 'scheduled' ||
          (startTime is DateTime && startTime.isBefore(now));
    }).toList();

    return result.take(5).toList();
  }

  Map<String, Color> statusBadgeStyle(String status) {
    final Map<String, Map<String, Color>> colors = {
      'scheduled': {
        'background': const Color(0xFFBEE3F8),
        'text': const Color(0xFF2C5282),
      },
      'completed': {
        'background': const Color(0xFFC6F6D5),
        'text': const Color(0xFF276749),
      },
      'cancelled': {
        'background': const Color(0xFFFED7D7),
        'text': const Color(0xFF9B2C2C),
      },
      'no_show': {
        'background': const Color(0xFFFEEBC8),
        'text': const Color(0xFF9C4221),
      },
    };

    return colors[status] ??
        {
          'background': const Color(0xFFE2E8F0),
          'text': const Color(0xFF4A5568),
        };
  }

  Future<void> confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF9B2C2C),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    });
  }

  Future<void> handleCancel(Map<String, dynamic> appointment) async {
    if (isCancellationLocked(appointment)) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Cancellation locked'),
            content: const Text('Appointments can no longer be cancelled within 24 hours of the scheduled time.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }

    final DateTime startTime = appointment['start_time'] as DateTime;

    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel appointment?'),
          content: Text(
            '${appointment['service_name']} on ${formatRelativeDate(startTime)} at ${formatTimeOnly(startTime)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep it'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Cancel appointment',
                style: TextStyle(
                  color: Color(0xFF9B2C2C),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !mounted) {
      return;
    }

    setState(() {
      appointment['status'] = 'cancelled';
    });

    await loadData();
  }

  Widget statusBadge(BuildContext context, String status) {
    final Map<String, Color> colors = statusBadgeStyle(status);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.003,
      ),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors['text'],
          fontSize: width * 0.027,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.04),
      decoration: const BoxDecoration(
        color: Color(0xFF1A365D),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'ToothConnect',
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) {
                      return;
                    }

                    Navigator.pushNamed(
                      context,
                      '/notifications',
                    );
                  });
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      '🔔',
                      style: TextStyle(
                        fontSize: width * 0.055,
                        color: Colors.white,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -MediaQuery.of(context).size.height * 0.005,
                        right: -width * 0.02,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: width * 0.045,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.012,
                            vertical: MediaQuery.of(context).size.height * 0.001,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53E3E),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.025,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: width * 0.02),
              TextButton(
                onPressed: confirmLogout,
                child: Text(
                  'Sign out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bookCard(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            Navigator.pushNamed(
              context,
              '/book-service',
            );
          });
        },
        child: Container(
          width: width,
          margin: EdgeInsets.only(
            bottom: height * 0.02,
          ),
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFF1A365D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book an appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      'AI-suggested slots based on your history',
                      style: TextStyle(
                        color: const Color(0xFFCBD5E0),
                        fontSize: width * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '→',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.055,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget featureCard(
    BuildContext context,
    String title,
    String subtitle,
    String route,
  ) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            Navigator.pushNamed(
              context,
              route,
            );
          });
        },
        child: Container(
          width: width,
          margin: EdgeInsets.only(
            bottom: height * 0.015,
          ),
          padding: EdgeInsets.all(width * 0.035),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF1A365D),
                        fontSize: width * 0.037,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: height * 0.004),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF718096),
                        fontSize: width * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '→',
                style: TextStyle(
                  color: const Color(0xFF2C7A7B),
                  fontSize: width * 0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(
        top: height * 0.01,
        bottom: height * 0.01,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: width * 0.032,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A5568),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget appointmentCard(
    BuildContext context,
    Map<String, dynamic> appointment, {
    bool showCancel = false,
  }) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final DateTime startTime = appointment['start_time'] as DateTime;
    final bool cancellationLocked = isCancellationLocked(appointment);

    return Container(
      width: width,
      margin: EdgeInsets.only(
        bottom: height * 0.012,
      ),
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${formatRelativeDate(startTime)} · ${formatTimeOnly(startTime)}',
                  style: TextStyle(
                    fontSize: width * 0.037,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A365D),
                  ),
                ),
              ),
              statusBadge(
                context,
                appointment['status'].toString(),
              ),
            ],
          ),
          SizedBox(height: height * 0.005),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${appointment['service_name']} with ${appointment['dentist_name']}',
              style: TextStyle(
                fontSize: width * 0.032,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              appointment['branch_name'].toString(),
              style: TextStyle(
                fontSize: width * 0.027,
                color: const Color(0xFF718096),
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (showCancel)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: cancellationLocked
                    ? null
                    : () {
                        handleCancel(appointment);
                      },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.only(
                    top: height * 0.012,
                    left: 0,
                    right: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: cancellationLocked
                        ? const Color(0xFFA0AEC0)
                        : const Color(0xFF9B2C2C),
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget emptyAppointments(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Text('No upcoming appointments.\nTap "Book" above to schedule one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF718096),
            fontSize: width * 0.032,
          ),
        ),
      ),
    );
  }

  Widget loadingContent(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(width * 0.05),
      child: Center(
        child: Text(
          'Loading...',
          style: TextStyle(
            color: const Color(0xFF718096),
            fontSize: width * 0.032,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            header(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${getUserName()}',
                        style: TextStyle(
                          fontSize: width * 0.055,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A365D),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      if (getUserEmail().isNotEmpty)
                        Text(
                          getUserEmail(),
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: const Color(0xFF718096),
                          ),
                        ),
                      SizedBox(height: height * 0.025),
                      bookCard(context),
                      featureCard(context, 'Treatment progress', 'View your treatments per tooth', '/treatment-progress'),
                      featureCard(context, 'Messages', 'Chat with the clinic reception', '/messages-list'),
                      sectionTitle(context, 'Upcoming'),
                      if (loading)
                        loadingContent(context)
                      else if (upcoming.isEmpty)
                        emptyAppointments(context)
                      else
                        ...upcoming.map(
                          (appointment) => appointmentCard(
                            context,
                            appointment,
                            showCancel: true,
                          ),
                        ),
                      if (past.isNotEmpty) ...[
                        sectionTitle(
                          context,
                          'Recent',
                        ),
                        ...past.map(
                          (appointment) => appointmentCard(
                            context,
                            appointment,
                          ),
                        ),
                      ],
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
}