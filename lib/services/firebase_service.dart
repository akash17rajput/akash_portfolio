import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import '../models/portfolio_models.dart';
import '../core/constants/app_constants.dart';

/// Service layer for all Firebase Firestore operations
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Projects ────────────────────────────────────────────────────────────

  /// Stream of all projects ordered by 'order' field
  Stream<List<ProjectModel>> getProjectsStream() {
    return _firestore
        .collection(AppConstants.projectsCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList())
        .handleError((error) {
      // Return sample projects on error (e.g., Firebase not configured)
      return sampleProjects;
    });
  }

  /// Fetch projects once (non-stream)
  Future<List<ProjectModel>> getProjects() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.projectsCollection)
          .orderBy('order')
          .get();
      return snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Return sample data if Firebase is not configured
      return sampleProjects;
    }
  }

  /// Add a new project
  Future<void> addProject(ProjectModel project) async {
    await _firestore
        .collection(AppConstants.projectsCollection)
        .add(project.toFirestore());
  }

  /// Update an existing project
  Future<void> updateProject(ProjectModel project) async {
    await _firestore
        .collection(AppConstants.projectsCollection)
        .doc(project.id)
        .update(project.toFirestore());
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    await _firestore
        .collection(AppConstants.projectsCollection)
        .doc(projectId)
        .delete();
  }

  // ─── Messages ────────────────────────────────────────────────────────────

  /// Submit a contact form message
  Future<void> submitMessage(MessageModel message) async {
    await _firestore
        .collection(AppConstants.messagesCollection)
        .add(message.toFirestore());
  }

  /// Stream of all messages (for admin)
  Stream<List<MessageModel>> getMessagesStream() {
    return _firestore
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  /// Mark message as read
  Future<void> markMessageRead(String messageId) async {
    await _firestore
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .update({'isRead': true});
  }

  // ─── Portfolio Data (Profile, Skills, Experience) ────────────────────────

  Stream<ProfileModel?> getProfileStream() {
    return _firestore.collection('portfolio').doc('profile').snapshots().map(
      (doc) {
        if (!doc.exists) {
          debugPrint(
              'FirebaseService: profile document missing at portfolio/profile');
          return null;
        }
        debugPrint('FirebaseService: profile document data = ${doc.data()}');
        return ProfileModel.fromFirestore(doc);
      },
    );
  }

  Stream<List<SkillCategoryModel>> getSkillsStream() {
    return _firestore
        .collection('portfolio')
        .doc('data')
        .collection('skills')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SkillCategoryModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ExperienceModel>> getExperienceStream() {
    return _firestore
        .collection('portfolio')
        .doc('data')
        .collection('experience')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExperienceModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ProjectModel>> getPortfolioProjectsStream() {
    return _firestore
        .collection('portfolio')
        .doc('projects')
        .collection('items')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // ─── Seed Data ───────────────────────────────────────────────────────────

  /// Seed Firestore with sample projects (run once for setup)
  Future<void> seedSampleProjects() async {
    final batch = _firestore.batch();
    for (final project in sampleProjects) {
      // Use ordered document IDs so they appear sequentially in the Firebase Console
      final docId = 'project_${project.id.padLeft(2, '0')}'; 
      final ref = _firestore.collection(AppConstants.projectsCollection).doc(docId);
      batch.set(ref, project.toFirestore());
    }
    await batch.commit();
  }

  /// Seed Firestore with profile, skills, and experience from AppConstants
  Future<void> seedPortfolioData() async {
    final batch = _firestore.batch();

    // 1. Profile
    final profileRef = _firestore.collection('portfolio').doc('profile');
    final profile = ProfileModel(
      name: AppConstants.developerName,
      role: AppConstants.developerRole,
      email: AppConstants.developerEmail,
      phone: AppConstants.developerPhone,
      location: AppConstants.developerLocation,
      experience: AppConstants.developerExperience,
      githubUrl: AppConstants.githubUrl,
      linkedinUrl: AppConstants.linkedinUrl,
      twitterUrl: AppConstants.twitterUrl,
      resumeUrl: AppConstants.resumeUrl,
      profileUrl: AppConstants.profileUrl,
      typingTexts: AppConstants.typingTexts,
      aboutHighlights: AppConstants.aboutHighlights
          .map((h) => HighlightModel(
                icon: h['icon'] ?? '',
                title: h['title'] ?? '',
                subtitle: h['subtitle'] ?? '',
              ))
          .toList(),
    );
    batch.set(profileRef, profile.toFirestore());

    // 2. Skills
    int skillOrder = 0;
    for (final s in AppConstants.skillsData) {
      final ref = _firestore
          .collection('portfolio')
          .doc('data')
          .collection('skills')
          .doc();
      final category = SkillCategoryModel(
        id: ref.id,
        category: s['category'] as String,
        order: skillOrder++,
        skills: (s['skills'] as List).map((skillMap) {
          return SkillModel(
            name: skillMap['name'] as String,
            level: (skillMap['level'] as num).toDouble(),
          );
        }).toList(),
      );
      batch.set(ref, category.toFirestore());
    }

    // 3. Experience
    int expOrder = 0;
    for (final e in AppConstants.experienceData) {
      final ref = _firestore
          .collection('portfolio')
          .doc('data')
          .collection('experience')
          .doc();
      final exp = ExperienceModel(
        id: ref.id,
        role: e['role'] as String,
        company: e['company'] as String,
        duration: e['duration'] as String,
        location: e['location'] as String,
        description: e['description'] as String,
        technologies: List<String>.from(e['technologies'] as List),
        isCurrent: e['isCurrent'] as bool,
        order: expOrder++,
      );
      batch.set(ref, exp.toFirestore());
    }

    await batch.commit();
  }
}
