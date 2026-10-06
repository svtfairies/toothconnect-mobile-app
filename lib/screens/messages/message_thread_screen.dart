import 'package:flutter/material.dart';
import '../../glob/users.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({super.key});

  @override
  State<MessageThreadScreen> createState() => MessageThreadScreenState();
}

class MessageThreadScreenState extends State<MessageThreadScreen> {
  static const int messageMaxLength = 2000;
  static const String messageMaxLengthError = 'Your message must not exceed 2000 characters';

  bool loading = true;
  bool refreshing = false;
  bool sending = false;
  bool isOnline = true;

  String error = '';
  String composerError = '';
  String composer = '';

  final TextEditingController composerController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String otherUserName = 'Reception Staff';
  String otherUserRole = 'receptionist';
  String branchName = 'Main Branch';
  int? branchId;

  List<Map<String, dynamic>> get messages => AllUsers.messageList;

  Map<String, dynamic> get currentUser {
    return AllUsers.currentUser ?? {'id': 0, 'name': 'My Account'};
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      otherUserName = arguments['otherUserName']?.toString() ?? 'Reception Staff';
      otherUserRole = arguments['otherUserRole']?.toString() ?? 'receptionist';
      branchName = _formatBranchTitle(arguments['branchName']?.toString() ?? 'Clinic');
      branchId = int.tryParse(arguments['branchId']?.toString() ?? '');
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    _scrollToBottom(false);
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (!mounted) return;

    if (!silent) {
      setState(() {
        loading = true;
        error = '';
      });
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (!silent) {
      setState(() {
        loading = false;
      });
    }

    _scrollToBottom(false);
  }

  Future<void> _fetchPresence() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    setState(() {
      isOnline = true;
    });
  }

  Future<void> _handleRefresh() async {
    if (!mounted || refreshing) return;

    setState(() {
      refreshing = true;
      error = '';
    });

    await _fetchMessages(silent: true);
    await _fetchPresence();

    if (!mounted) return;

    setState(() {
      refreshing = false;
    });
  }

  Future<void> _handleSend() async {
    if (!mounted) return;

    final messageText = composerController.text.trim();
    final isOverLimit = composerController.text.length > messageMaxLength;

    if (messageText.isEmpty || sending) return;

    if (isOverLimit) {
      setState(() {
        composerError = messageMaxLengthError;
      });
      return;
    }

    setState(() {
      sending = true;
      error = '';
      composerError = '';
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    final receiverId = branchId == 2
        ? 102
        : branchId == 3
            ? 103
            : 101;

    AllUsers.messageList.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender_id': currentUser['id'],
      'receiver_id': receiverId,
      'content': messageText,
      'created_at': DateTime.now(),
      'is_read': false,
      'branch_id': branchId ?? 1,
    });

    composerController.clear();

    setState(() {
      composer = '';
      sending = false;
      composerError = '';
    });

    _scrollToBottom(true);
  }

  void _handleComposerChanged(String value) {
    if (!mounted) return;

    setState(() {
      composer = value;
      composerError = value.length > messageMaxLength ? messageMaxLengthError : '';
    });
  }

  void _scrollToBottom(bool animated) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      final maxExtent = scrollController.position.maxScrollExtent;

      if (animated && maxExtent > 0) {
        scrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(maxExtent);
      }
    });
  }

  void _goBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  String _formatBubbleTime(DateTime? date) {
    if (date == null) return '';

    final hour = date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length > 2 ? 2 : value.length).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  String _displayRole() {
    return isOnline ? 'Online' : 'Offline';
  }

  String _getSelfMessageStatus(Map<String, dynamic> message) {
    return message['is_read'] == true ? 'Read' : 'Delivered';
  }

  String _formatBranchTitle(String name) {
    final branch = name.trim().isEmpty ? 'Clinic' : name.trim();

    if (RegExp(r'\bbranch\b', caseSensitive: false).hasMatch(branch)) {
      return branch;
    }

    return '$branch Branch';
  }

  List<Map<String, dynamic>> _visibleMessages() {
    return messages.where((message) {
      final messageBranchId = int.tryParse(message['branch_id']?.toString() ?? '');

      return messageBranchId == null || branchId == null || messageBranchId == branchId;
    }).toList();
  }

  Widget _header(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.055).clamp(18.0, 24.0);
    
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _goBack,
              icon: const Text(
                '‹',
                style: TextStyle(
                  color: Color(0xFFB97B00),
                  fontSize: 38,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
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
                  blurRadius: 9,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials(branchName),
                style: const TextStyle(
                  color: Color(0xFFB97B00),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF171717),
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF0AA33A) : const Color(0xFF8F8F8F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      _displayRole(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOnline ? const Color(0xFF0AA33A) : const Color(0xFF8F8F8F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(BuildContext context, Map<String, dynamic> message) {
    final isSelf = message['sender_id'] == currentUser['id'];

    final messageDate = message['created_at'] is DateTime
        ? message['created_at'] as DateTime
        : DateTime.tryParse(message['created_at']?.toString() ?? '') ?? DateTime.now();

    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.025,
        ),
        child: Column(
          crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isSelf ? const Color(0xFFFFF1CF) : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message['content']?.toString() ?? '',
                style: const TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 15,
                  height: 1.47,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatBubbleTime(messageDate)}${isSelf ? ' • ${_getSelfMessageStatus(message)}' : ''}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFB97B00),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messages(BuildContext context) {
    final visibleMessages = _visibleMessages();

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFFC98B00),
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.011,
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.032,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Today',
                style: TextStyle(
                  color: Color(0xFFB97B00),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                ),
              )
            else if (visibleMessages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No messages yet. Say hello.',
                    style: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...visibleMessages.map(
                (message) => _messageBubble(context, message),
              ),
          ],
        ),
      ),
    );
  }

  Widget _error() {
    if (error.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(10),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFFFD7D7)),
        ),
      ),
      child: Text(
        error,
        style: const TextStyle(
          color: Color(0xFF9B2C2C),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _composer(BuildContext context) {
    final isOverLimit = composer.length > messageMaxLength;
    final isDisabled = sending || composer.trim().isEmpty || isOverLimit;

    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    TextField(
                      controller: composerController,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !sending,
                      onChanged: _handleComposerChanged,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8F8F8F),
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(21),
                          borderSide: BorderSide(
                            color: isOverLimit ? const Color(0xFFE3342F) : Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(21),
                          borderSide: BorderSide(
                            color: isOverLimit ? const Color(0xFFE3342F) : Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(21),
                          borderSide: BorderSide(
                            color: isOverLimit ? const Color(0xFFE3342F) : Colors.white,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF171717),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 6,
                      child: Text(
                        '${composer.length}/$messageMaxLength',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isOverLimit ? const Color(0xFFE3342F) : const Color(0xFF8F8F8F),
                        ),
                      ),
                    ),
                  ],
                ),
                if (composerError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 12, right: 12),
                    child: Text(
                      composerError,
                      style: const TextStyle(
                        color: Color(0xFFE3342F),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: isDisabled ? null : _handleSend,
              style: IconButton.styleFrom(
                backgroundColor: isDisabled ? const Color(0xFFD8B86B) : const Color(0xFFC98B00),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD8B86B),
                disabledForegroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              icon: Text(
                sending ? '...' : '➤',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    composerController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Column(
                children: [
                  _messages(context),
                  _error(),
                  _composer(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}