import 'package:flutter/material.dart';
import '../../glob/users.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? currentUser;
  int selectedBranchId = 1;
  int? expandedServiceId;

  final List<Map<String, dynamic>> branches = [
    {'id': 1, 'name': 'Main Branch', 'address': 'Makati City', 'operating_hours': 'Monday - Saturday, 8:00 AM - 5:00 PM', 'dentist_count': 5, 'service_count': 10, 'years_active': '8'},
    {'id': 2, 'name': 'Quezon Branch', 'address': 'Quezon City', 'operating_hours': 'Monday - Saturday, 8:00 AM - 5:00 PM', 'dentist_count': 4, 'service_count': 9, 'years_active': '6'},
    {'id': 3, 'name': 'Pasig Branch', 'address': 'Pasig City', 'operating_hours': 'Monday - Saturday, 8:00 AM - 5:00 PM', 'dentist_count': 3, 'service_count': 8, 'years_active': '5'},
  ];

  final Map<String, dynamic> upcomingAppointment = {
    'service_name': 'Teeth Whitening',
    'date': 'October 10, 2026',
    'time': '10:00 AM',
    'dentist_name': 'Dr. Maria Santos',
  };

  final List<Map<String, dynamic>> dentists = [
    {'id': 1, 'name': 'Dr. Maria Santos', 'services': 'General Dentistry', 'branch': 'Makati City', 'schedule': 'Mon, Wed, Fri', 'branchId': 1},
    {'id': 2, 'name': 'Dr. John Cruz', 'services': 'Orthodontics', 'branch': 'Makati City', 'schedule': 'Tue, Thu, Sat', 'branchId': 1},
    {'id': 3, 'name': 'Dr. Angela Reyes', 'services': 'Cosmetic Dentistry', 'branch': 'Quezon City', 'schedule': 'Mon, Wed, Fri', 'branchId': 2},
    {'id': 4, 'name': 'Dr. Kevin Garcia', 'services': 'General Dentistry', 'branch': 'Pasig City', 'schedule': 'Tue, Thu, Sat', 'branchId': 3},
  ];

  final List<Map<String, dynamic>> services = [
    {'id': 1, 'name': 'Deep Scaling', 'price': 1500, 'duration': 60, 'description': 'Professional deep cleaning to remove plaque and tartar.', 'category': 'Preventive'},
    {'id': 2, 'name': 'Teeth Whitening', 'price': 5000, 'duration': 90, 'description': 'Professional whitening treatment for a brighter smile.', 'category': 'Cosmetic'},
    {'id': 3, 'name': 'Veneers', 'price': 12000, 'duration': 120, 'description': 'Custom-made dental veneers for improved tooth appearance.', 'category': 'Cosmetic'},
    {'id': 4, 'name': 'Root Canal Treatment', 'price': 8000, 'duration': 90, 'description': 'Treatment for infected or damaged tooth pulp.', 'category': 'Restorative'},
    {'id': 5, 'name': 'Orthodontics', 'price': 35000, 'duration': 60, 'description': 'Dental treatment for correcting tooth alignment.', 'category': 'Orthodontics'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (AllUsers.currentUser != null) {
      currentUser = AllUsers.currentUser;
    } else if (args is Map<String, dynamic>) {
      currentUser = args;
      AllUsers.currentUser = args;
    }
    final userBranchId = int.tryParse(currentUser?['branchId']?.toString() ?? '');
    if (userBranchId != null && branches.any((branch) => branch['id'] == userBranchId)) {
      selectedBranchId = userBranchId;
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String getUserName() {
    final name = currentUser?['name']?.toString().trim();
    if (name == null || name.isEmpty) return 'My Account';
    return name;
  }

  String getUserBranch() {
    final branchAddress = currentUser?['branchAddress']?.toString().trim();
    if (branchAddress != null && branchAddress.isNotEmpty) return branchAddress;
    final branchName = currentUser?['branchName']?.toString().trim();
    if (branchName != null && branchName.isNotEmpty) {
      final matchingBranch = branches.where((branch) => branch['name'].toString() == branchName);
      if (matchingBranch.isNotEmpty) return matchingBranch.first['address'].toString();
      return branchName;
    }
    return 'Home branch not assigned';
  }

  Map<String, dynamic> get selectedBranch {
    return branches.firstWhere((branch) => branch['id'] == selectedBranchId, orElse: () => branches.first);
  }

  List<Map<String, dynamic>> get displayedDentists {
    return dentists.where((dentist) => dentist['branchId'] == selectedBranchId).toList();
  }

  String getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    if (words.length >= 2) return '${words.first[0]}${words.last[0]}'.toUpperCase();
    return words.isNotEmpty ? words.first[0].toUpperCase() : 'A';
  }

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
                padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.04, MediaQuery.of(context).size.height * 0.022, MediaQuery.of(context).size.width * 0.04, MediaQuery.of(context).size.height * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    greeting(context),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                    appointmentCard(context),
                    sectionTitle(context, 'About the Clinic'),
                    clinicCard(context),
                    sectionTitle(context, 'Our Dentists'),
                    dentistsSection(context),
                    sectionTitle(context, 'Our Services'),
                    servicesSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.075,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.045),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Row(
        children: [
          Builder(builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: Icon(Icons.menu, size: MediaQuery.of(context).size.width * 0.075, color: const Color(0xFFB47A00)))),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Expanded(child: Text('Dashboard', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06, fontWeight: FontWeight.w900, fontFamily: 'Georgia'))),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(onPressed: () => Navigator.pushNamed(context, '/notifications'), icon: Icon(Icons.notifications_none, size: MediaQuery.of(context).size.width * 0.07, color: const Color(0xFFB47A00))),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.002,
                right: MediaQuery.of(context).size.width * 0.002,
                child: Container(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.045),
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.012, vertical: MediaQuery.of(context).size.height * 0.001),
                  decoration: BoxDecoration(color: const Color(0xFFE53E3E), borderRadius: BorderRadius.circular(999)),
                  child: Text('2', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.025, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget greeting(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.022),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${getGreeting()}, ${getUserName()}', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.065, fontWeight: FontWeight.w900, color: const Color(0xFFB47A00), fontFamily: 'Georgia')),
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.height * 0.009),
            decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HOME BRANCH', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.022, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w800)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.002),
                Text(getUserBranch(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.033, color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget appointmentCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: MediaQuery.of(context).size.height * 0.022),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: MediaQuery.of(context).size.width * 0.02, offset: Offset(0, MediaQuery.of(context).size.height * 0.004))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UPCOMING APPOINTMENT', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.027, color: const Color(0xFF64748B), fontWeight: FontWeight.w700, letterSpacing: MediaQuery.of(context).size.width * 0.002)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(upcomingAppointment['service_name'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055, color: const Color(0xFF1F2937), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
          SizedBox(height: MediaQuery.of(context).size.height * 0.012),
          Wrap(
            spacing: MediaQuery.of(context).size.width * 0.018,
            runSpacing: MediaQuery.of(context).size.height * 0.005,
            children: [
              Text(upcomingAppointment['date'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.034, color: const Color(0xFF374151), fontWeight: FontWeight.w700)),
              Text('•', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: MediaQuery.of(context).size.width * 0.034)),
              Text(upcomingAppointment['time'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.034, color: const Color(0xFF374151), fontWeight: FontWeight.w700)),
              Text('•', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: MediaQuery.of(context).size.width * 0.034)),
              Text(upcomingAppointment['dentist_name'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.034, color: const Color(0xFF374151), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.018, bottom: MediaQuery.of(context).size.height * 0.015),
      child: Row(
        children: [
          Text('•', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w900)),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text(title, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.047, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
        ],
      ),
    );
  }

  Widget clinicCard(BuildContext context) {
    final branch = selectedBranch;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: MediaQuery.of(context).size.width * 0.02, offset: Offset(0, MediaQuery.of(context).size.height * 0.004))]),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.045, MediaQuery.of(context).size.height * 0.02, MediaQuery.of(context).size.width * 0.045, MediaQuery.of(context).size.height * 0.016),
              child: Text('Branches', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045, color: const Color(0xFFB47A00), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
              scrollDirection: Axis.horizontal,
              itemCount: branches.length,
              separatorBuilder: (context, index) => SizedBox(width: MediaQuery.of(context).size.width * 0.025),
              itemBuilder: (context, index) {
                final item = branches[index];
                final active = item['id'] == selectedBranchId;

                return GestureDetector(
                  onTap: () => setState(() => selectedBranchId = item['id']),
                  child: Container(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.34),
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: active ? const Color(0xFFC98904) : Colors.white, border: Border.all(color: const Color(0xFFE4CF88)), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.045)),
                    child: Text(item['address'], textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.033, color: active ? Colors.white : const Color(0xFF1F1F1F), fontWeight: FontWeight.w800)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.045),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE4CF88)), bottom: BorderSide(color: Color(0xFFE4CF88)))),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC98904), width: MediaQuery.of(context).size.width * 0.005)),
                  child: Text(getInitials(branch['name']), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: const Color(0xFFC98904), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.038),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(branch['name'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.047, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.007),
                      Text(branch['address'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.033, color: const Color(0xFF1F1F1F), height: 1.4)),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.007),
                      Text(branch['operating_hours'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.033, color: const Color(0xFF1F1F1F))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.018),
            color: const Color(0xFFF7F8FC),
            child: Row(
              children: [
                stat(context, '${branch['dentist_count']}', 'Dentists'),
                statDivider(context),
                stat(context, '${branch['service_count']}', 'Services'),
                statDivider(context),
                stat(context, '${branch['years_active']}', 'Years Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stat(BuildContext context, String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(number, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06, color: const Color(0xFFB47A00), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.032, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget statDivider(BuildContext context) {
    return Container(width: MediaQuery.of(context).size.width * 0.0025, height: MediaQuery.of(context).size.height * 0.045, color: const Color(0xFFD6BC70));
  }

  Widget dentistsSection(BuildContext context) {
    if (displayedDentists.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.12,
        child: Center(
          child: Text('No dentists found.', style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.035)),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final dentistListHeight = screenHeight < 650 ? 235.0 : screenHeight * 0.34;

    return SizedBox(
      height: dentistListHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayedDentists.length,
        itemBuilder: (context, index) {
          final dentist = displayedDentists[index];

          return Container(
            width: MediaQuery.of(context).size.width * 0.48,
            margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.04, bottom: MediaQuery.of(context).size.height * 0.006),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.045),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFF0ECE4)), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04), boxShadow: [BoxShadow(color: const Color(0x21000000), blurRadius: MediaQuery.of(context).size.width * 0.028, offset: Offset(0, MediaQuery.of(context).size.height * 0.006))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.012),
                  decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.035)),
                  child: Text(getInitials(dentist['name']), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06, color: const Color(0xFF4B6CB7), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
                ),
                Text(dentist['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w900)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text(dentist['services'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.032, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w600)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.009),
                Text('📍 ${dentist['branch']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: const Color(0xFF8A650E), fontWeight: FontWeight.w700)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                Text('● ${dentist['schedule']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: const Color(0xFF169C45), fontWeight: FontWeight.w800)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget servicesSection(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025)),
      child: Column(
        children: services.map((service) {
          final expanded = expandedServiceId == service['id'];

          if (expandedServiceId != null && !expanded) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onTap: () => setState(() => expandedServiceId = expanded ? null : service['id']),
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.012),
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.035, vertical: expanded ? MediaQuery.of(context).size.height * 0.018 : MediaQuery.of(context).size.height * 0.015),
              decoration: BoxDecoration(color: expanded ? const Color(0xFFFFF8E7) : Colors.white, borderRadius: BorderRadius.circular(expanded ? MediaQuery.of(context).size.width * 0.025 : MediaQuery.of(context).size.width * 0.02)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(service['name'], style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.038, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w800))),
                      if (!expanded) Text('${service['duration']} mins', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.032, color: const Color(0xFF8A650E), fontWeight: FontWeight.w700)),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Text(expanded ? '▲' : '▼', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: const Color(0xFFB47A00), fontWeight: FontWeight.w900)),
                    ],
                  ),
                  if (expanded) ...[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    Container(width: MediaQuery.of(context).size.width, height: 1, color: const Color(0xFFF0E8CC)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    serviceDetail(context, 'Estimated Amount', '₱${service['price']}'),
                    serviceDetail(context, 'Duration', '${service['duration']} mins'),
                    serviceDetail(context, 'About', service['description'], alignLeft: true),
                    serviceDetail(context, 'Category', service['category']),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                    GestureDetector(
                      onTap: () => setState(() => expandedServiceId = null),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.009, horizontal: MediaQuery.of(context).size.width * 0.045),
                        decoration: BoxDecoration(color: const Color(0xFFE8EAF0), borderRadius: BorderRadius.circular(999)),
                        child: Text('Show all services', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: const Color(0xFFB47A00), fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget serviceDetail(BuildContext context, String label, String value, {bool alignLeft = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.032, color: const Color(0xFF8A650E), fontWeight: FontWeight.w800))),
          Expanded(flex: 2, child: Text(value, textAlign: alignLeft ? TextAlign.left : TextAlign.right, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.032, color: const Color(0xFF1F1F1F), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget drawer() {
    final userName = getUserName();
    final userInitials = getInitials(userName);
    final userBranch = getUserBranch();

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
                    decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(11)),
                    child: Center(child: Text(userInitials, style: const TextStyle(fontSize: 20, color: Color(0xFFB47A00), fontWeight: FontWeight.w900, fontFamily: 'Georgia'))),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, color: Color(0xFFB47A00), fontWeight: FontWeight.w900, fontFamily: 'Georgia')),
                        const SizedBox(height: 4),
                        Text(userBranch, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF8A650E))),
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
                    drawerItem(context, Icons.home_outlined, 'Home', true, () => Navigator.pop(context)),
                    drawerItem(context, Icons.person_outline, 'Profile', false, () { Navigator.pop(context); Navigator.pushNamed(context, '/profile'); }),
                    drawerItem(context, Icons.message_outlined, 'Message', false, () { Navigator.pop(context); Navigator.pushNamed(context, '/messages-list'); }),
                    drawerItem(context, Icons.calendar_today_outlined, 'Appointments', false, () { Navigator.pop(context); Navigator.pushNamed(context, '/appointments'); }),
                    drawerItem(context, Icons.folder_outlined, 'History', false, () { Navigator.pop(context); Navigator.pushNamed(context, '/records'); }),
                    drawerItem(context, Icons.folder_copy_outlined, 'Treatment Plan', false, () { Navigator.pop(context); Navigator.pushNamed(context, '/dental-treatment-plan'); }),
                    drawerItem(context, Icons.notifications_none, 'Notifications', false, () { Navigator.pop(context); Navigator.pushNamed(context, '/notifications'); }),
                  ],
                ),
              ),
              const Divider(height: 29, color: Color(0xFFE0E0E0)),
              drawerItem(context, Icons.logout, 'Sign Out', false, () { AllUsers.currentUser = null; Navigator.pop(context); Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(BuildContext context, IconData icon, String title, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: active ? const Color(0xFFFFF8E7) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(icon, size: 20, color: const Color(0xFFB47A00)),
          title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFFB47A00), fontWeight: FontWeight.w700, fontFamily: 'Georgia')),
          onTap: onTap,
        ),
      ),
    );
  }
}