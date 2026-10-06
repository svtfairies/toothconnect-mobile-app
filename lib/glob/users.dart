class AllUsers {
  static final List<Map<String, dynamic>> userList = [];

  static Map<String, dynamic>? currentUser;

  static final List<Map<String, dynamic>> messageList = [
    {
      'id': 1,
      'sender_id': 101,
      'receiver_id': 1,
      'content': 'Good day! How can we assist you today?',
      'created_at': DateTime(2026, 10, 6, 9, 10),
      'is_read': true,
      'branch_id': 1,
    },
    {
      'id': 2,
      'sender_id': 1,
      'receiver_id': 101,
      'content': 'Good day! I would like to confirm my upcoming appointment.',
      'created_at': DateTime(2026, 10, 6, 9, 15),
      'is_read': true,
      'branch_id': 1,
    },
    {
      'id': 3,
      'sender_id': 101,
      'receiver_id': 1,
      'content': 'Your Teeth Whitening appointment with Dr. Maria Santos is confirmed.',
      'created_at': DateTime(2026, 10, 6, 9, 18),
      'is_read': true,
      'branch_id': 1,
    },
  ];
}