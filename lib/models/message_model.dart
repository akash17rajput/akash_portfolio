import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a contact form submission
class MessageModel {
  final String? id;
  final String name;
  final String email;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  /// Create from Firestore document
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  @override
  String toString() => 'MessageModel(name: $name, email: $email)';
}
