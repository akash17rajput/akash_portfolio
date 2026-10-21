import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/firebase_service.dart';

enum ContactStatus { idle, loading, success, error }

/// Provider for managing contact form state
class ContactProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  ContactStatus _status = ContactStatus.idle;
  String? _errorMessage;

  ContactStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ContactStatus.loading;

  /// Submit contact form to Firestore
  Future<void> submitMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    _status = ContactStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = MessageModel(
        name: name.trim(),
        email: email.trim(),
        message: message.trim(),
        timestamp: DateTime.now(),
      );
      await _firebaseService.submitMessage(msg);
      _status = ContactStatus.success;
    } catch (e, stack) {
      debugPrint('ContactProvider.submitMessage error: $e\n$stack');
      _status = ContactStatus.error;
      _errorMessage = 'Failed to send message. Please try again.';
    }

    notifyListeners();
  }

  /// Reset form status
  void reset() {
    _status = ContactStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Helper for unit tests
  @visibleForTesting
  void setStatusForTesting(ContactStatus status, [String? errorMessage]) {
    _status = status;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
