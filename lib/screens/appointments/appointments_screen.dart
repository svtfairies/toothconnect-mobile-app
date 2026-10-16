import 'package:flutter/material.dart';
import '../../glob/users.dart';

class AppointmentScreenState extends StatefulWidget {
  const AppointmentScreenState({super.key});

  @override
  State<AppointmentScreenState> createState() => AppointmentScreen();
}

class AppointmentScreen extends State<AppointmentScreenState> {
  Map<String, dynamic>? currentUser;
  int selectedBranchId = 1;
  int? expandedServiceId;

  String selectedFilter = 'All';
  String selectedTab = 'Upcoming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      drawer: drawer(),
      body: SafeArea(
        child: Column(
          children: [
            header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.04,
                  MediaQuery.of(context).size.height * 0.022,
                  MediaQuery.of(context).size.width * 0.04,
                  MediaQuery.of(context).size.height * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    bookAppointmentButton(context),
                    const SizedBox(height: 20),
                    dateFilterRow(),
                    const SizedBox(height: 20),
                    appointmentTabRow(),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedTab == 'Upcoming'
                            ? 'Upcoming Appointments'
                            : 'Appointment History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: Colors.black,
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
    );
  }

  Widget bookAppointmentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/book-appointment'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Book an Appointment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB47A00),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget dateFilterRow() {
    const filters = ['All', 'This week', 'This month'];
    return Row(
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => setState(() => selectedFilter = filter),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? const Color(0xFFFFF3D6)
                    : Colors.white,
                foregroundColor: const Color(0xFFB47A00),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFB47A00)
                      : const Color(0xFFE0D5BC),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  filter,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget appointmentTabRow() {
    return Row(
      children: [
        Expanded(child: appointmentTab('Upcoming')),
        const SizedBox(width: 12),
        Expanded(child: appointmentTab('History')),
      ],
    );
  }

  final Map<String, dynamic> upcomingAppointment = {
    'service_name': 'Teeth Whitening',
    'date': 'October 10, 2026',
    'time': '10:00 AM',
    'dentist_name': 'Dr. Maria Santos',
  };

  Widget appointmentTab(String title) {
    final isSelected = selectedTab == title;
    return InkWell(
      onTap: () => setState(() => selectedTab = title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3D6) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFFB47A00)
                  : const Color(0xFFE0E0E0),
              width: isSelected ? 2.5 : 1,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? const Color(0xFFB47A00)
                : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.075,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.045,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                Icons.menu,
                size: MediaQuery.of(context).size.width * 0.075,
                color: const Color(0xFFB47A00),
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Expanded(
            child: Text(
              'Appointments',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.w900,
                fontFamily: 'Georgia',
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
                icon: Icon(
                  Icons.notifications_none,
                  size: MediaQuery.of(context).size.width * 0.07,
                  color: const Color(0xFFB47A00),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.002,
                right: MediaQuery.of(context).size.width * 0.002,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.045,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.012,
                    vertical: MediaQuery.of(context).size.height * 0.001,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '2',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.025,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget drawer() {
    final userName = "CODEIVGECO";
    final userInitials = "CV";
    final userBranch = "MOA";

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.9,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
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
                        userInitials,
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
                        Text(
                          userName,
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
                        Text(
                          userBranch,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
              const Divider(height: 29, color: Color(0xFFE0E0E0)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    drawerItem(context, Icons.home_outlined, 'Home', false, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/home');
                    }),
                    drawerItem(
                      context,
                      Icons.person_outline,
                      'Profile',
                      false,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    drawerItem(
                      context,
                      Icons.message_outlined,
                      'Message',
                      false,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/messages-list');
                      },
                    ),
                    drawerItem(
                      context,
                      Icons.calendar_today_outlined,
                      'Appointments',
                      true,
                      () => Navigator.pop(context),
                    ),
                    drawerItem(
                      context,
                      Icons.folder_outlined,
                      'History',
                      false,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/records');
                      },
                    ),
                    drawerItem(
                      context,
                      Icons.folder_copy_outlined,
                      'Treatment Plan',
                      false,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/dental-treatment-plan');
                      },
                    ),
                    drawerItem(
                      context,
                      Icons.notifications_none,
                      'Notifications',
                      false,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 29, color: Color(0xFFE0E0E0)),
              drawerItem(context, Icons.logout, 'Sign Out', false, () {
                AllUsers.currentUser = null;
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    bool active,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: active ? const Color(0xFFFFF8E7) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(icon, size: 20, color: const Color(0xFFB47A00)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFB47A00),
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
