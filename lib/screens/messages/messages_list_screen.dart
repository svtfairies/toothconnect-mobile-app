import 'package:flutter/material.dart';
import '../../glob/users.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => MessagesListScreenState();
}

class MessagesListScreenState extends State<MessagesListScreen> {
  bool loading = true;
  bool refreshing = false;
  String searchQuery = '';
  String filterMode = 'all';
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> threads = [
    {
      'branch_id': 1,
      'other_user_id': 101,
      'other_user_name': 'Reception Staff',
      'other_user_role': 'receptionist',
      'branch_name': 'Main Branch',
      'branch_address': 'Makati City',
      'last_message_body': 'Your appointment has been confirmed.',
      'last_message_at': DateTime(2026, 10, 6, 18, 10),
      'unread_count': 2,
    },
    {
      'branch_id': 2,
      'other_user_id': 102,
      'other_user_name': 'Reception Staff',
      'other_user_role': 'receptionist',
      'branch_name': 'Quezon Branch',
      'branch_address': 'Quezon City',
      'last_message_body': 'Please bring your previous dental records.',
      'last_message_at': DateTime(2026, 10, 6, 15, 30),
      'unread_count': 0,
    },
    {
      'branch_id': 3,
      'other_user_id': 103,
      'other_user_name': 'Reception Staff',
      'other_user_role': 'receptionist',
      'branch_name': 'Pasig Branch',
      'branch_address': 'Pasig City',
      'last_message_body': 'Thank you for contacting our clinic.',
      'last_message_at': DateTime(2026, 10, 5, 11, 20),
      'unread_count': 1,
    },
  ];

  final List<Map<String, dynamic>> contacts = [
    {
      'id': 1,
      'branch_id': 1,
      'branch_name': 'Main Branch',
      'branch_address': 'Makati City',
      'receptionist_id': 101,
      'receptionist_name': 'Reception Staff',
      'can_message': true,
    },
    {
      'id': 2,
      'branch_id': 2,
      'branch_name': 'Quezon Branch',
      'branch_address': 'Quezon City',
      'receptionist_id': 102,
      'receptionist_name': 'Reception Staff',
      'can_message': true,
    },
    {
      'id': 3,
      'branch_id': 3,
      'branch_name': 'Pasig Branch',
      'branch_address': 'Pasig City',
      'receptionist_id': 103,
      'receptionist_name': 'Reception Staff',
      'can_message': false,
    },
  ];

  Map<String, dynamic> get currentUser {
    return AllUsers.currentUser ?? {'name': 'My Account', 'branchAddress': 'My Branch'};
  }

  @override
  void initState() {
    super.initState();
    fetchMessagesData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String getUserName() {
    final name = currentUser['name']?.toString().trim();
    if (name == null || name.isEmpty) return 'My Account';
    return name;
  }

  String getUserBranch() {
    final branchAddress = currentUser['branchAddress']?.toString().trim();
    if (branchAddress != null && branchAddress.isNotEmpty) return branchAddress;

    final homeBranchCity = currentUser['home_branch_city']?.toString().trim();
    if (homeBranchCity != null && homeBranchCity.isNotEmpty) return homeBranchCity;

    final branchName = currentUser['branchName']?.toString().trim();
    if (branchName != null && branchName.isNotEmpty) return branchName;

    return 'My Branch';
  }

  String getUserInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';

    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length > 2 ? 2 : value.length).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> fetchMessagesData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      loading = false;
      refreshing = false;
    });
  }

  Future<void> refreshMessages() async {
    if (!mounted) return;

    setState(() {
      refreshing = true;
    });

    await fetchMessagesData();
  }

  Future<void> openContactPicker() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => contactPickerSection(sheetContext),
    );
  }

  void navigateToMessageThread(Map<String, dynamic> contact) {
    if (!mounted) return;

    final disabled = contact['can_message'] != true || contact['receptionist_id'] == null;
    if (disabled) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/message-thread',
        arguments: {
          'otherUserId': contact['receptionist_id'],
          'otherUserName': contact['receptionist_name'],
          'otherUserRole': 'receptionist',
          'branchId': contact['id'] ?? contact['branch_id'],
          'branchName': getBranchTitle(contact),
        },
      );
    });
  }

  void pickContact(Map<String, dynamic> contact) {
    navigateToMessageThread(contact);
  }

  void openContactFromPicker(BuildContext sheetContext, Map<String, dynamic> contact) {
    final disabled = contact['can_message'] != true || contact['receptionist_id'] == null;
    if (disabled) return;

    Navigator.pop(sheetContext);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/message-thread',
        arguments: {
          'otherUserId': contact['receptionist_id'],
          'otherUserName': contact['receptionist_name'],
          'otherUserRole': 'receptionist',
          'branchId': contact['id'] ?? contact['branch_id'],
          'branchName': getBranchTitle(contact),
        },
      );
    });
  }

  void openNotificationPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/notifications');
    });
  }

  void openRoute(String route) {
    if (!mounted || route == '/messages-list') return;

    Navigator.pop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamed(context, route);
    });
  }

  String previewTime(dynamic value) {
    if (value == null) return '';

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) return '';

    final now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      final hour = date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${months[date.month - 1]} ${date.day}';
  }

  String getBranchLocation(Map<String, dynamic> item) {
    final address = item['branch_address']?.toString().trim();
    final name = item['branch_name']?.toString().trim();

    if (address != null && address.isNotEmpty) return address;

    if (name != null && name.isNotEmpty) {
      return name.replaceAll(RegExp(r'\s+Branch$', caseSensitive: false), '');
    }

    return 'Unknown';
  }

  String getBranchTitle(Map<String, dynamic> item) {
    final branchLocation = getBranchLocation(item);

    if (RegExp(r'\bbranch\b', caseSensitive: false).hasMatch(branchLocation)) {
      return branchLocation;
    }

    return '$branchLocation Branch';
  }

  String getBranchDisplay(Map<String, dynamic> item) {
    return getBranchTitle(item);
  }

  String branchInitials(Map<String, dynamic> item) {
    final branchLocation = getBranchLocation(item);

    final parts = branchLocation.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length > 2 ? 2 : value.length).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> confirmLogout() async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    AllUsers.currentUser = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });
  }

  List<Map<String, dynamic>> getVisibleThreads() {
    final searchText = searchQuery.trim().toLowerCase();

    return threads.where((thread) {
      final branchLocation = getBranchLocation(thread).toLowerCase();
      final branchTitle = getBranchTitle(thread).toLowerCase();
      final receptionistName = (thread['other_user_name'] ?? '').toString().toLowerCase();
      final lastMessage = (thread['last_message_body'] ?? '').toString().toLowerCase();

      final matchesSearch = searchText.isEmpty ||
          branchLocation.contains(searchText) ||
          branchTitle.contains(searchText) ||
          receptionistName.contains(searchText) ||
          lastMessage.contains(searchText);

      final unreadCount = int.tryParse(thread['unread_count']?.toString() ?? '0') ?? 0;
      final matchesFilter = filterMode == 'all' || unreadCount > 0;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int getUnreadMessageCount() {
    return threads.fold(
      0,
      (total, thread) => total + (int.tryParse(thread['unread_count']?.toString() ?? '0') ?? 0),
    );
  }

  Widget headerSection() {
    return Builder(
      builder: (headerContext) => Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Scaffold.of(headerContext).openDrawer(),
                icon: const Text(
                  '☰',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFFB47A00),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171717),
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: openNotificationPage,
                icon: const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Color(0xFFB47A00),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget branchContactsSection() {
    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final disabled = contact['can_message'] != true || contact['receptionist_id'] == null;

          return GestureDetector(
            onTap: disabled ? null : () => pickContact(contact),
            child: Container(
              width: 78,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: disabled ? const Color(0xFFF2F2F2) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: disabled
                          ? []
                          : const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                offset: Offset(0, 5),
                                blurRadius: 9,
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        branchInitials(contact),
                        style: TextStyle(
                          fontSize: 20,
                          color: disabled ? const Color(0xFFC0C0C0) : const Color(0xFFB47A00),
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contact['receptionist_name']?.toString() ?? getBranchTitle(contact),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: disabled ? const Color(0xFFC0C0C0) : const Color(0xFF171717),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget searchSection() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '⌕',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF7F7F7F),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF171717),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  searchController.clear();
                  setState(() => searchQuery = '');
                },
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF7F7F7F),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget filterSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => filterMode = 'all'),
            child: Container(
              width: 92,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: filterMode == 'all' ? const Color(0xFFC98B00) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    offset: Offset(0, 5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: filterMode == 'all' ? Colors.white : const Color(0xFF171717),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => filterMode = 'unread'),
            child: Container(
              width: 92,
              height: 40,
              decoration: BoxDecoration(
                color: filterMode == 'unread' ? const Color(0xFFC98B00) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    offset: Offset(0, 5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Unread',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: filterMode == 'unread' ? Colors.white : const Color(0xFF171717),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget threadItem(Map<String, dynamic> thread) {
    final unreadCount = int.tryParse(thread['unread_count']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.pushNamed(
            context,
            '/message-thread',
            arguments: {
              'otherUserId': thread['other_user_id'],
              'otherUserName': thread['other_user_name'],
              'otherUserRole': thread['other_user_role'],
              'branchId': thread['branch_id'],
              'branchName': getBranchTitle(thread),
            },
          );
        });
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 4),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              margin: const EdgeInsets.only(right: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 5),
                    blurRadius: 9,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  branchInitials(thread),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          getBranchTitle(thread),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF171717),
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        previewTime(thread['last_message_at']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB47A00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${getBranchTitle(thread)} · ${thread['other_user_name']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2F2F2F),
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC98B00),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileSection() {
    final userName = getUserName();
    final userBranch = getUserBranch();
    final initials = getUserInitials(userName);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Row(
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
                initials,
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
              mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget menuItem(IconData icon, String title, String route, bool active, int unreadCount) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openRoute(route),
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF8E7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFFB47A00),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
            if (unreadCount > 0)
              Container(
                constraints: const BoxConstraints(minWidth: 24),
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget signOutSection() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: confirmLogout,
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Icon(
                  Icons.logout,
                  size: 20,
                  color: Color(0xFFB47A00),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Sign Out',
                style: TextStyle(
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
    );
  }

  Widget sidebarSection() {
    final unreadMessageCount = getUnreadMessageCount();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.9,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
          child: Column(
            children: [
              profileSection(),
              const Divider(
                height: 29,
                color: Color(0xFFE0E0E0),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      menuItem(Icons.home_outlined, 'Home', '/home', false, 0),
                      menuItem(Icons.person_outline, 'Profile', '/profile', false, 0),
                      menuItem(Icons.message_outlined, 'Message', '/messages-list', true, unreadMessageCount),
                      menuItem(Icons.calendar_today_outlined, 'Appointments', '/appointments', false, 0),
                      menuItem(Icons.folder_outlined, 'History', '/records', false, 0),
                      menuItem(Icons.folder_copy_outlined, 'Treatment Plan', '/dental-treatment-plan', false, 0),
                      menuItem(Icons.notifications_none, 'Notifications', '/notifications', false, 0),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 29,
                color: Color(0xFFE0E0E0),
              ),
              signOutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget contactPickerSection(BuildContext sheetContext) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick who you want to message.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6F6F6F),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final disabled = contact['can_message'] != true || contact['receptionist_id'] == null;

                return GestureDetector(
                  onTap: disabled ? null : () => openContactFromPicker(sheetContext, contact),
                  child: Opacity(
                    opacity: disabled ? 0.55 : 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFF2F2F2),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getBranchTitle(contact),
                            style: TextStyle(
                              fontSize: 14,
                              color: disabled ? const Color(0xFF6F6F6F) : const Color(0xFF171717),
                              fontWeight: disabled ? FontWeight.w400 : FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            disabled ? 'Available after an appointment at this branch.' : contact['receptionist_name'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: disabled ? const Color(0xFFB0B0B0) : const Color(0xFF6F6F6F),
                              fontStyle: disabled ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(sheetContext),
            child: const SizedBox(
              width: double.infinity,
              height: 40,
              child: Center(
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB47A00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingSection() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6F6F6F),
          ),
        ),
      ),
    );
  }

  Widget emptySection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Text(
              'No conversations yet.\nStart one to talk with the clinic.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6F6F6F),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: openContactPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC98B00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Start a conversation',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget noResultsSection() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 28),
        child: Text(
          'No messages found.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6F6F6F),
          ),
        ),
      ),
    );
  }

  Widget messagesContentSection() {
    if (loading) {
      return loadingSection();
    }

    final visibleThreads = getVisibleThreads();

    if (threads.isEmpty) {
      return emptySection();
    }

    if (visibleThreads.isEmpty) {
      return noResultsSection();
    }

    return RefreshIndicator(
      color: const Color(0xFFC98B00),
      onRefresh: refreshMessages,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: visibleThreads.length,
        itemBuilder: (context, index) => threadItem(visibleThreads[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      drawer: sidebarSection(),
      drawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Column(
          children: [
            headerSection(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchSection(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: messagesContentSection(),
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
}