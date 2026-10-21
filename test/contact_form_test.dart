import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:akash_portfolio/providers/contact_provider.dart';
import 'package:akash_portfolio/providers/portfolio_provider.dart';
import 'package:akash_portfolio/widgets/contact/contact_section.dart';

class MockContactProvider extends ContactProvider {
  bool submitCalled = false;
  String? submittedName;
  String? submittedEmail;
  String? submittedMessage;

  @override
  Future<void> submitMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    submitCalled = true;
    submittedName = name;
    submittedEmail = email;
    submittedMessage = message;
    setStatusForTesting(ContactStatus.success);
  }
}

class MockErrorContactProvider extends ContactProvider {
  @override
  Future<void> submitMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    setStatusForTesting(ContactStatus.error, 'Network error');
  }
}

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  Widget createWidgetUnderTest({ContactProvider? contactProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactProvider>(
          create: (_) => contactProvider ?? ContactProvider(),
        ),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ContactSection(),
          ),
        ),
      ),
    );
  }

  group('ContactForm Validation & Submission Tests', () {
    testWidgets('shows validation errors when submitting empty form', (tester) async {
      tester.view.physicalSize = const Size(1920, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find and tap "Send Message" button
      final sendButton = find.text('Send Message');
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Check required error messages
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Message is required'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      tester.view.physicalSize = const Size(1920, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'not-an-email');
      await tester.enterText(textFields.at(2), 'This is a valid long message for testing.');

      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsNothing);
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Message is required'), findsNothing);
    });

    testWidgets('validates message length (< 10 chars)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Test User');
      await tester.enterText(textFields.at(1), 'test@example.com');
      await tester.enterText(textFields.at(2), 'Hi!');

      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      expect(find.text('Message must be at least 10 characters'), findsOneWidget);
    });

    testWidgets('submits successfully and clears fields and shows success SnackBar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockProvider = MockContactProvider();
      await tester.pumpWidget(createWidgetUnderTest(contactProvider: mockProvider));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Akash');
      await tester.enterText(textFields.at(1), 'akash@example.com');
      await tester.enterText(textFields.at(2), 'Hello! I want to hire you for a Flutter project.');

      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      expect(mockProvider.submitCalled, isTrue);
      expect(mockProvider.submittedName, equals('Akash'));
      expect(mockProvider.submittedEmail, equals('akash@example.com'));
      expect(mockProvider.submittedMessage, equals('Hello! I want to hire you for a Flutter project.'));

      // Verify success SnackBar message
      expect(find.text('Message sent successfully! I\'ll get back to you soon.'), findsOneWidget);

      // Verify text fields were cleared
      expect(find.text('Akash'), findsNothing);
      expect(find.text('akash@example.com'), findsNothing);
      expect(find.text('Hello! I want to hire you for a Flutter project.'), findsNothing);
    });

    testWidgets('shows error SnackBar on submission error', (tester) async {
      tester.view.physicalSize = const Size(1920, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockProvider = MockErrorContactProvider();
      await tester.pumpWidget(createWidgetUnderTest(contactProvider: mockProvider));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Akash');
      await tester.enterText(textFields.at(1), 'akash@example.com');
      await tester.enterText(textFields.at(2), 'Hello! I want to hire you for a Flutter project.');

      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      // Verify error SnackBar
      expect(find.text('Network error'), findsOneWidget);
    });
  });
}
